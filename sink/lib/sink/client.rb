# frozen_string_literal: true

require 'net/http'
require 'json'
require 'fileutils'
require 'cgi'

module Sink
  class Client
    CONNECT_TIMEOUT = 5
    READ_TIMEOUT    = 60

    def initialize
      @config = Config.new
    end

    def sync
      puts 'Scanning local network for sink peers...'
      peers = Discovery.peers(@config.port)
      if peers.empty?
        puts 'No sink peers found.'
        return
      end

      local = Manifest.new(@config.sync_dirs).scan

      peers.each do |ip|
        puts "Syncing with #{ip}..."
        sync_peer(ip, local)
      rescue => e
        warn "  Error: #{e.message}"
      end
    end

    def status
      puts 'Scanning local network for sink peers...'
      peers = Discovery.peers(@config.port)
      if peers.empty?
        puts 'No peers found.'
      else
        peers.each { |ip| puts "  #{ip}:#{@config.port}  online" }
      end
    end

    private

    def sync_peer(ip, local_manifest)
      body = get(ip, '/manifest')
      unless body
        warn '  Could not fetch manifest.'
        return
      end

      remote  = Manifest.from_json(body)
      pulled  = 0
      pushed  = 0

      @config.sync_dirs.each do |dir_name, root|
        local_idx  = index(local_manifest.dirs[dir_name] || [])
        remote_idx = index(remote.dirs[dir_name]         || [])

        (local_idx.keys + remote_idx.keys).uniq.each do |rel_path|
          l = local_idx[rel_path]
          r = remote_idx[rel_path]

          if l.nil?
            pull(ip, dir_name, rel_path, root) && pulled += 1
          elsif r.nil?
            push(ip, dir_name, rel_path, root, l) && pushed += 1
          elsif l.sha256 != r.sha256
            if r.mtime > l.mtime
              pull(ip, dir_name, rel_path, root) && pulled += 1
            else
              push(ip, dir_name, rel_path, root, l) && pushed += 1
            end
          end
        end
      end

      puts "  pulled=#{pulled} pushed=#{pushed}"
    end

    def index(entries)
      entries.each_with_object({}) { |e, h| h[e.rel_path] = e }
    end

    def pull(ip, dir_name, rel_path, root)
      res = http(ip, Net::HTTP::Get, file_url(dir_name, rel_path))
      return false unless res&.code&.to_i == 200

      abs = File.join(root, rel_path)
      FileUtils.mkdir_p(File.dirname(abs))
      File.binwrite(abs, res.body)
      if (s = res['X-Sink-Mtime'])&.match?(/\A[\d.]+\z/)
        t = Time.at(s.to_f)
        File.utime(t, t, abs)
      end
      true
    rescue => e
      warn "  pull #{rel_path}: #{e.message}"; false
    end

    def push(ip, dir_name, rel_path, root, entry)
      abs = File.join(root, rel_path)
      return false unless File.file?(abs)

      res = http(ip, Net::HTTP::Put, file_url(dir_name, rel_path),
                 body: File.binread(abs), mtime: entry.mtime)
      (res&.code&.to_i || 0).between?(200, 204)
    rescue => e
      warn "  push #{rel_path}: #{e.message}"; false
    end

    def file_url(dir_name, rel_path)
      "/file?dir=#{CGI.escape(dir_name)}&path=#{CGI.escape(rel_path)}"
    end

    def get(ip, path)
      res = http(ip, Net::HTTP::Get, path)
      res&.code&.to_i == 200 ? res.body : nil
    end

    def http(ip, method_class, path, body: nil, mtime: nil)
      Net::HTTP.start(ip, @config.port,
                      open_timeout: CONNECT_TIMEOUT,
                      read_timeout: READ_TIMEOUT) do |h|
        req = method_class.new(path)
        req['X-Sink-Mtime'] = mtime.to_s if mtime
        req.body = body if body
        h.request(req)
      end
    rescue => e
      warn "  #{method_class::METHOD} #{path}: #{e.message}"; nil
    end
  end
end
