# frozen_string_literal: true

require_relative 'test_helper'

class FakeDiscoverer
  attr_reader :calls

  def initialize(peers)
    @peers = peers
    @calls = 0
  end

  def peers(_port)
    @calls += 1
    @peers
  end
end

class PeerCacheTest < Minitest::Test
  def test_peers_falls_back_to_a_live_scan_when_no_cache_file_exists
    with_tmp_state_dir do |state_dir|
      discoverer = FakeDiscoverer.new(['10.0.0.5'])
      config     = FakeConfig.new(7070, '0.0.0.0', {}, state_dir)
      cache      = Sink::PeerCache.new(config, discoverer: discoverer)

      assert_equal ['10.0.0.5'], cache.peers
      assert_equal 1, discoverer.calls
    end
  end

  def test_refresh_writes_a_cache_that_peers_then_reads_without_rescanning
    with_tmp_state_dir do |state_dir|
      discoverer = FakeDiscoverer.new(['10.0.0.5'])
      config     = FakeConfig.new(7070, '0.0.0.0', {}, state_dir)
      cache      = Sink::PeerCache.new(config, discoverer: discoverer)

      cache.refresh!
      assert_equal ['10.0.0.5'], cache.peers
      assert_equal 1, discoverer.calls
    end
  end

  def test_peers_falls_back_to_a_live_scan_when_the_cache_is_stale
    with_tmp_state_dir do |state_dir|
      stale_discoverer = FakeDiscoverer.new(['10.0.0.5'])
      config           = FakeConfig.new(7070, '0.0.0.0', {}, state_dir)
      Sink::PeerCache.new(config, discoverer: stale_discoverer).refresh!

      cache_path = File.join(state_dir, 'peers.json')
      data       = JSON.parse(File.read(cache_path))
      data['updated_at'] = Time.now.to_f - Sink::PeerCache::STALE_AFTER - 1
      File.write(cache_path, JSON.generate(data))

      fresh_discoverer = FakeDiscoverer.new(['10.0.0.9'])
      cache            = Sink::PeerCache.new(config, discoverer: fresh_discoverer)

      assert_equal ['10.0.0.9'], cache.peers
      assert_equal 1, fresh_discoverer.calls
    end
  end

  def test_peers_falls_back_to_a_live_scan_when_the_cache_file_is_corrupt
    with_tmp_state_dir do |state_dir|
      config = FakeConfig.new(7070, '0.0.0.0', {}, state_dir)
      File.write(File.join(state_dir, 'peers.json'), 'not json')

      discoverer = FakeDiscoverer.new(['10.0.0.9'])
      cache      = Sink::PeerCache.new(config, discoverer: discoverer)

      assert_equal ['10.0.0.9'], cache.peers
    end
  end
end
