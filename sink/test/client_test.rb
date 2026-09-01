# frozen_string_literal: true

require_relative 'test_helper'
require 'timeout'

class FakePeerCache
  def initialize(peers) = @peers = peers
  def peers = @peers
end

class ClientSyncTest < Minitest::Test
  def setup
    @peer_root  = Dir.mktmpdir('sink-peer-sync')
    @peer_state = Dir.mktmpdir('sink-peer-state')
    peer_config = FakeConfig.new(0, '127.0.0.1', { 'notes' => @peer_root }, @peer_state)
    @peer       = Sink::Server.new(peer_config, peer_cache: NullPeerCache.new)
    @peer_thread = Thread.new { @peer.start }
    Timeout.timeout(2) { sleep 0.01 until @peer.port }

    @local_root  = Dir.mktmpdir('sink-local-sync')
    @local_state = Dir.mktmpdir('sink-local-state')
    client_config = FakeConfig.new(@peer.port, '0.0.0.0', { 'notes' => @local_root }, @local_state)
    @client = Sink::Client.new(client_config, peer_cache: FakePeerCache.new(['127.0.0.1']))
  end

  def teardown
    @peer_thread.kill
    @peer.stop
    [@peer_root, @peer_state, @local_root, @local_state].each { |d| FileUtils.remove_entry(d) }
  end

  def test_sync_pushes_a_newly_added_local_file_to_the_peer
    File.write(File.join(@local_root, 'a.txt'), 'hello')

    @client.sync

    assert_equal 'hello', File.read(File.join(@peer_root, 'a.txt'))
  end

  def test_sync_pushes_a_locally_modified_file_to_the_peer
    File.write(File.join(@local_root, 'a.txt'), 'hello')
    @client.sync

    File.write(File.join(@local_root, 'a.txt'), 'goodbye')
    @client.sync

    assert_equal 'goodbye', File.read(File.join(@peer_root, 'a.txt'))
  end

  def test_sync_deletes_a_locally_removed_file_on_the_peer
    File.write(File.join(@local_root, 'a.txt'), 'hello')
    @client.sync

    File.delete(File.join(@local_root, 'a.txt'))
    @client.sync

    refute File.exist?(File.join(@peer_root, 'a.txt'))
    tombstones = JSON.parse(File.read(File.join(@peer_state, 'notes.tombstones.json')))
    assert tombstones.key?('a.txt')
  end

  def test_sync_does_nothing_when_no_peers_are_cached
    client = Sink::Client.new(
      FakeConfig.new(@peer.port, '0.0.0.0', { 'notes' => @local_root }, @local_state),
      peer_cache: FakePeerCache.new([])
    )

    client.sync
  end
end
