# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'sink'
require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'

FakeConfig = Struct.new(:port, :bind, :sync_dirs, :state_dir)

class NullPeerCache
  attr_reader :refresh_started

  def initialize
    @refresh_started = false
  end

  def start_background_refresh!
    @refresh_started = true
  end
end

module SinkTestHelpers
  def with_tmp_state_dir
    Dir.mktmpdir('sink-state') { |dir| yield dir }
  end

  def with_tmp_sync_dir
    Dir.mktmpdir('sink-sync') { |dir| yield dir }
  end
end

Minitest::Test.include(SinkTestHelpers)
