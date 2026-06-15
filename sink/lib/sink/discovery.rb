# frozen_string_literal: true

require 'socket'
require 'timeout'
require 'net/http'

module Sink
  module Discovery
    CONCURRENCY = 64

    def self.peers(port)
      base = local_subnet
      return [] unless base

      my_ips = own_ips
      candidates = (1..254).map { |i| "#{base}.#{i}" }.reject { |ip| my_ips.include?(ip) }

      found = []
      mutex = Mutex.new

      candidates.each_slice(CONCURRENCY) do |batch|
        batch.map { |ip|
          Thread.new do
            next unless tcp_open?(ip, port)
            next unless sink_server?(ip, port)
            mutex.synchronize { found << ip }
          end
        }.each(&:join)
      end

      found.sort
    end

    def self.local_subnet
      Socket.ip_address_list
            .select { |a| a.ipv4? && !a.ipv4_loopback? }
            .map(&:ip_address)
            .find { |ip| ip.match?(/\A(192\.168\.|10\.|172\.(1[6-9]|2\d|3[01])\.)/) }
            &.sub(/\.\d+\z/, '')
    end

    def self.own_ips
      Socket.ip_address_list.select(&:ipv4?).map(&:ip_address)
    end

    def self.tcp_open?(ip, port)
      Timeout.timeout(0.5) { TCPSocket.new(ip, port).close; true }
    rescue
      false
    end

    def self.sink_server?(ip, port)
      res = Net::HTTP.start(ip, port, open_timeout: 1, read_timeout: 2) { |h| h.get('/ping') }
      res.code.to_i == 200
    rescue
      false
    end
  end
end
