# frozen_string_literal: true

require_relative 'test_helper'
require 'net/http'
require 'timeout'

class ServerStateWriteThroughTest < Minitest::Test
  def setup
    @sync_root  = Dir.mktmpdir('sink-sync')
    @state_dir  = Dir.mktmpdir('sink-state')
    config      = FakeConfig.new(0, '127.0.0.1', { 'notes' => @sync_root }, @state_dir)
    @peer_cache = NullPeerCache.new
    @server     = Sink::Server.new(config, peer_cache: @peer_cache)
    @thread     = Thread.new { @server.start }
    Timeout.timeout(2) { sleep 0.01 until @server.port }
  end

  def teardown
    @thread.kill
    @server.stop
    FileUtils.remove_entry(@sync_root)
    FileUtils.remove_entry(@state_dir)
  end

  def test_put_immediately_updates_the_state_snapshot
    put('a.txt', 'hello')

    saved = JSON.parse(File.read(File.join(@state_dir, 'notes.state.json')))
    entry = saved.find { |e| e['path'] == 'a.txt' }
    refute_nil entry
    assert_equal Digest::SHA256.hexdigest('hello'), entry['sha256']
    assert_equal 5, entry['size']
  end

  def test_start_triggers_background_peer_cache_refresh
    assert @peer_cache.refresh_started
  end

  def test_delete_immediately_removes_the_state_snapshot_entry
    put('a.txt', 'hello')
    delete('a.txt')

    saved = JSON.parse(File.read(File.join(@state_dir, 'notes.state.json')))
    assert_empty saved.select { |e| e['path'] == 'a.txt' }
  end

  private

  def put(rel_path, body)
    Net::HTTP.start('127.0.0.1', @server.port) do |h|
      req = Net::HTTP::Put.new("/file?dir=notes&path=#{rel_path}")
      req.body = body
      h.request(req)
    end
  end

  def delete(rel_path)
    Net::HTTP.start('127.0.0.1', @server.port) do |h|
      h.request(Net::HTTP::Delete.new("/file?dir=notes&path=#{rel_path}"))
    end
  end
end
