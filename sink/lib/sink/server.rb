# frozen_string_literal: true

require 'socket'
require 'json'
require 'fileutils'
require 'cgi'

module Sink
  class Server
    STATUS_MSG = {
      200 => 'OK', 204 => 'No Content', 400 => 'Bad Request',
      403 => 'Forbidden', 404 => 'Not Found', 405 => 'Method Not Allowed'
    }.freeze

    class Request
      attr_reader :method, :path, :headers, :query, :body
      def initialize(method, path, headers, query, body)
        @method, @path, @headers, @query, @body = method, path, headers, query, body
      end
    end

    class Response
      attr_accessor :status, :body
      attr_reader :headers

      def initialize
        @status  = 200
        @body    = ''
        @headers = { 'Content-Type' => 'text/plain' }
      end

      def content_type=(val)
        @headers['Content-Type'] = val
      end

      def []=(key, val)
        @headers[key] = val
      end
    end

    def initialize
      @config = Config.new
    end

    def start
      tcp = TCPServer.new(@config.bind, @config.port)
      $stdout.puts "sink server on #{@config.bind}:#{@config.port}"
      $stdout.flush

      trap('INT')  { tcp.close; exit }
      trap('TERM') { tcp.close; exit }

      loop do
        conn = tcp.accept
        Thread.new(conn) { |c| handle(c) }
      end
    end

    private

    def handle(conn)
      conn.binmode
      line = conn.gets&.chomp
      return unless line

      http_method, full_path, = line.split(' ', 3)
      path, qs = full_path.to_s.split('?', 2)
      query   = parse_qs(qs)
      headers = {}

      while (h = conn.gets&.chomp) && !h.empty?
        k, v = h.split(': ', 2)
        headers[k.downcase] = v
      end

      body = nil
      if (len = headers['content-length']&.to_i)&.positive?
        body = conn.read(len)
      end

      req = Request.new(http_method, path, headers, query, body)
      res = Response.new
      dispatch(req, res)
      write_response(conn, res)
    rescue => e
      warn "sink: #{e.message}"
    ensure
      conn.close rescue nil
    end

    def dispatch(req, res)
      case req.path
      when '/ping'     then handle_ping(req, res)
      when '/manifest' then handle_manifest(req, res)
      when '/file'     then handle_file(req, res)
      else
        res.status = 404
        res.body   = 'Not found'
      end
    end

    def handle_ping(_req, res)
      res.content_type = 'application/json'
      res.body = JSON.generate(ok: true, host: Socket.gethostname)
    end

    def handle_manifest(_req, res)
      res.content_type = 'application/json'
      res.body = Manifest.new(@config.sync_dirs).scan.to_json
    end

    def handle_file(req, res)
      dir_name = req.query['dir']
      rel_path = req.query['path']

      unless dir_name && rel_path
        res.status = 400; res.body = 'Missing dir or path'; return
      end

      root = @config.sync_dirs[dir_name]
      unless root
        res.status = 404; res.body = 'Unknown dir'; return
      end

      abs = File.join(root, rel_path)
      unless abs.start_with?("#{root}/")
        res.status = 403; res.body = 'Forbidden'; return
      end

      case req.method
      when 'GET'
        unless File.file?(abs)
          res.status = 404; res.body = 'Not found'; return
        end
        res.content_type     = 'application/octet-stream'
        res['X-Sink-Mtime']  = File.mtime(abs).to_f.to_s
        res.body             = File.binread(abs)

      when 'PUT'
        FileUtils.mkdir_p(File.dirname(abs))
        File.binwrite(abs, req.body || '')
        if (s = req.headers['x-sink-mtime'])&.match?(/\A[\d.]+\z/)
          t = Time.at(s.to_f)
          File.utime(t, t, abs)
        end
        res.status = 204
        res.body   = ''

      else
        res.status = 405; res.body = 'Method not allowed'
      end
    end

    def write_response(conn, res)
      conn.write("HTTP/1.1 #{res.status} #{STATUS_MSG[res.status] || 'Unknown'}\r\n")
      res.headers.each { |k, v| conn.write("#{k}: #{v}\r\n") }
      conn.write("Content-Length: #{res.body.bytesize}\r\n")
      conn.write("Connection: close\r\n\r\n")
      conn.write(res.body)
    rescue Errno::EPIPE
      nil
    end

    def parse_qs(qs)
      return {} unless qs
      qs.split('&').each_with_object({}) do |pair, h|
        k, v = pair.split('=', 2)
        h[CGI.unescape(k.to_s)] = CGI.unescape(v.to_s)
      end
    end
  end
end
