# frozen_string_literal: true

require 'json'
require 'fileutils'

module Sink
  class PeerCache
    REFRESH_INTERVAL = 45   # seconds between background LAN rescans
    STALE_AFTER       = 300 # seconds after which a cached peer list is ignored

    def initialize(config, discoverer: Discovery)
      @config     = config
      @discoverer = discoverer
      @path       = File.join(config.state_dir, 'peers.json')
    end

    def start_background_refresh!
      Thread.new do
        loop do
          refresh!
        rescue => e
          warn "sink: peer discovery refresh failed: #{e.message}"
        ensure
          sleep REFRESH_INTERVAL
        end
      end
    end

    def refresh!
      write(@discoverer.peers(@config.port))
    end

    def peers
      read || @discoverer.peers(@config.port)
    end

    private

    def read
      return nil unless File.exist?(@path)
      data = JSON.parse(File.read(@path))
      return nil if Time.now.to_f - data['updated_at'].to_f > STALE_AFTER

      data['peers']
    rescue
      nil
    end

    def write(ips)
      FileUtils.mkdir_p(File.dirname(@path))
      tmp = "#{@path}.tmp.#{Process.pid}"
      File.write(tmp, JSON.generate(peers: ips, updated_at: Time.now.to_f))
      File.rename(tmp, @path)
    end
  end
end
