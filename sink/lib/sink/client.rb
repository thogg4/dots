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

      local = Manifest.new(@config.sync_dirs, @config.state_dir).scan

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
      deleted = 0

      @config.sync_dirs.each do |dir_name, root|
        local_files  = index(local_manifest.dirs[dir_name] || [])
        remote_files = index(remote.dirs[dir_name] || [])
        local_tombs  = tomb_index(local_manifest.tombstones[dir_name] || [])
        remote_tombs = tomb_index(remote.tombstones[dir_name] || [])

        merged_tombs = merge_tombs(local_tombs, remote_tombs)

        (local_files.keys + remote_files.keys + merged_tombs.keys).uniq.each do |rel_path|
          l     = local_files[rel_path]
          r     = remote_files[rel_path]
          tomb  = merged_tombs[rel_path]

          if tomb
            newest_mtime = [l&.mtime, r&.mtime].compact.max
            # File re-created after deletion → file wins
            next if newest_mtime && newest_mtime > tomb.deleted_at

            if l
              FileUtils.rm_f(File.join(root, rel_path))
              Manifest.record_tombstone(@config.state_dir, dir_name, rel_path, tomb.deleted_at)
              deleted += 1
            end

            # Propagate tombstone to remote if it lacks it or has an older one
            remote_ts = remote_tombs[rel_path]&.deleted_at.to_f
            if r || remote_ts < tomb.deleted_at
              delete_remote(ip, dir_name, rel_path, tomb.deleted_at)
            end
          else
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
      end

      puts "  pulled=#{pulled} pushed=#{pushed} deleted=#{deleted}"
    end

    def index(entries)
      entries.each_with_object({}) { |e, h| h[e.rel_path] = e }
    end

    def tomb_index(tombstones)
      tombstones.each_with_object({}) { |t, h| h[t.rel_path] = t }
    end

    def merge_tombs(local_tombs, remote_tombs)
      (local_tombs.keys + remote_tombs.keys).uniq.each_with_object({}) do |path, h|
        l = local_tombs[path]
        r = remote_tombs[path]
        h[path] = (l && r) ? (l.deleted_at >= r.deleted_at ? l : r) : (l || r)
      end
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

    def delete_remote(ip, dir_name, rel_path, deleted_at)
      url = "/file?dir=#{CGI.escape(dir_name)}&path=#{CGI.escape(rel_path)}&deleted_at=#{deleted_at}"
      res = http(ip, Net::HTTP::Delete, url)
      (res&.code&.to_i || 0).between?(200, 204)
    rescue => e
      warn "  delete #{rel_path}: #{e.message}"; false
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
