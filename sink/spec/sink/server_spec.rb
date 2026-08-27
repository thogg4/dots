# frozen_string_literal: true

require 'net/http'
require 'socket'
require 'timeout'

RSpec.describe Sink::Server do
  around do |example|
    Dir.mktmpdir('sink-server-root') do |root|
      Dir.mktmpdir('sink-server-state') do |state_dir|
        @root      = root
        @state_dir = state_dir
        example.run
      end
    end
  end

  def free_port
    s = TCPServer.new('127.0.0.1', 0)
    s.addr[1]
  ensure
    s.close
  end

  def start_server
    port   = free_port
    config = FakeConfig.new(port: port, bind: '127.0.0.1', state_dir: @state_dir, sync_dirs: { 'notes' => @root })
    thread = Thread.new { described_class.new(config).start }

    Timeout.timeout(2) do
      loop do
        TCPSocket.new('127.0.0.1', port).close
        break
      rescue Errno::ECONNREFUSED
        sleep 0.01
      end
    end

    port
  ensure
    @threads_to_kill ||= []
    @threads_to_kill << thread if thread
  end

  after { @threads_to_kill&.each(&:kill) }

  describe 'DELETE /file' do
    context 'when the file exists' do
      it 'removes it, with no tombstone bookkeeping (the client owns tombstone truth via the synced hidden file)' do
        port = start_server
        File.write(File.join(@root, 'a.txt'), 'hello')

        res = Net::HTTP.start('127.0.0.1', port) { |h| h.delete('/file?dir=notes&path=a.txt') }

        expect(res.code).to eq('204')
        expect(File.exist?(File.join(@root, 'a.txt'))).to be false
      end
    end

    context 'when the file does not exist' do
      it 'still responds 204, since the end state (file absent) already holds' do
        port = start_server
        res  = Net::HTTP.start('127.0.0.1', port) { |h| h.delete('/file?dir=notes&path=missing.txt') }

        expect(res.code).to eq('204')
      end
    end
  end
end
