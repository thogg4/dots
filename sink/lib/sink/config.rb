# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module Sink
  class Config
    CONFIG_PATH = File.expand_path('~/.config/sink/config.yml')
    STATE_DIR   = File.expand_path('~/.local/share/sink')

    def initialize
      @data = load_config
    end

    def self.init
      FileUtils.mkdir_p(File.dirname(CONFIG_PATH))
      if File.exist?(CONFIG_PATH)
        puts "Config already exists at #{CONFIG_PATH}"
        return
      end
      File.write(CONFIG_PATH, <<~YAML)
        server:
          port: 7070
          bind: "0.0.0.0"

        # Named sync directories. Both peers must use the same names;
        # paths can differ per machine since ~ expands locally.
        sync_dirs:
          # notes: ~/Documents/notes
      YAML
      puts "Created config at #{CONFIG_PATH}"
    end

    def port      = @data.dig('server', 'port') || 7070
    def bind      = @data.dig('server', 'bind') || '0.0.0.0'
    def state_dir = STATE_DIR

    def sync_dirs
      (@data['sync_dirs'] || {}).transform_values { |p| File.expand_path(p) }
    end

    private

    def load_config
      unless File.exist?(CONFIG_PATH)
        warn "No config at #{CONFIG_PATH}. Run `sink init` to create one."
        exit 1
      end
      YAML.safe_load(File.read(CONFIG_PATH)) || {}
    end
  end
end
