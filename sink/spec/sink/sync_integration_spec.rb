# frozen_string_literal: true

require 'net/http'
require 'socket'
require 'timeout'

RSpec.describe 'sink sync' do
  # Both peers run on 127.0.0.1 under distinct ports, standing in for two
  # real machines that would each listen on the same configured sink port.
  LOOPBACK = '127.0.0.1'

  around do |example|
    Dir.mktmpdir('sink-a-root') do |a_root|
      Dir.mktmpdir('sink-a-state') do |a_state|
        Dir.mktmpdir('sink-b-root') do |b_root|
          Dir.mktmpdir('sink-b-state') do |b_state|
            @a_root, @a_state, @b_root, @b_state = a_root, a_state, b_root, b_state
            example.run
          end
        end
      end
    end
  end

  after { @threads&.each(&:kill) }

  def free_port
    s = TCPServer.new('127.0.0.1', 0)
    s.addr[1]
  ensure
    s.close
  end

  def start_peers
    a_port = free_port
    b_port = free_port

    server_a_config = FakeConfig.new(port: a_port, bind: LOOPBACK, state_dir: @a_state, sync_dirs: { 'notes' => @a_root })
    server_b_config = FakeConfig.new(port: b_port, bind: LOOPBACK, state_dir: @b_state, sync_dirs: { 'notes' => @b_root })
    # A dials out on B's port and vice versa, standing in for two machines
    # that each listen on the shared configured sink port.
    @a_config = FakeConfig.new(port: b_port, state_dir: @a_state, sync_dirs: { 'notes' => @a_root })
    @b_config = FakeConfig.new(port: a_port, state_dir: @b_state, sync_dirs: { 'notes' => @b_root })

    @threads = [server_a_config, server_b_config].map { |c| Thread.new { Sink::Server.new(c).start } }
    wait_until_listening(a_port)
    wait_until_listening(b_port)
  end

  def wait_until_listening(port)
    Timeout.timeout(2) do
      loop do
        TCPSocket.new(LOOPBACK, port).close
        return
      rescue Errno::ECONNREFUSED
        sleep 0.01
      end
    end
  end

  def sync_as(config)
    allow(Sink::Discovery).to receive(:peers).and_return([LOOPBACK])
    Sink::Client.new(config).sync
  end

  def write_file(root, rel_path, content = 'hello')
    abs = File.join(root, rel_path)
    FileUtils.mkdir_p(File.dirname(abs))
    File.write(abs, content)
  end

  def tombstones_on_disk(root)
    JSON.parse(File.read(File.join(root, Sink::Manifest::TOMBSTONE_FILENAME)))
  end

  describe 'deleting a file on one peer' do
    it 'deletes it on the other peer and converges both hidden tombstone files' do
      start_peers
      write_file(@a_root, 'a.txt')
      sync_as(@a_config) # b now has a.txt too
      expect(File.exist?(File.join(@b_root, 'a.txt'))).to be true

      File.delete(File.join(@a_root, 'a.txt'))
      sync_as(@a_config) # a detects + records the deletion, pushes it to b

      expect(File.exist?(File.join(@b_root, 'a.txt'))).to be false
      expect(tombstones_on_disk(@a_root)).to have_key('a.txt')
      expect(tombstones_on_disk(@b_root)).to have_key('a.txt')
    end
  end

  describe 're-creating a file after it was deleted and already synced as a tombstone' do
    it 'the newer file wins over the stale tombstone' do
      start_peers
      write_file(@a_root, 'a.txt')
      sync_as(@a_config)

      File.delete(File.join(@a_root, 'a.txt'))
      sync_as(@a_config)
      expect(File.exist?(File.join(@b_root, 'a.txt'))).to be false

      write_file(@b_root, 'a.txt', 'recreated')
      sync_as(@b_config)

      expect(File.exist?(File.join(@a_root, 'a.txt'))).to be true
      expect(File.read(File.join(@a_root, 'a.txt'))).to eq('recreated')
    end
  end
end
