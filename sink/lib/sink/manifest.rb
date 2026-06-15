# frozen_string_literal: true

require 'digest'
require 'json'

module Sink
  class Manifest
    Entry = Struct.new(:rel_path, :sha256, :mtime, :size, keyword_init: true)

    attr_reader :dirs

    def initialize(sync_dirs = {})
      @sync_dirs = sync_dirs
      @dirs = {}
    end

    def scan
      @sync_dirs.each { |name, root| @dirs[name] = scan_dir(root) }
      self
    end

    def to_json(*)
      JSON.generate(
        @dirs.transform_values { |entries|
          entries.map { |e| { path: e.rel_path, sha256: e.sha256, mtime: e.mtime, size: e.size } }
        }
      )
    end

    def self.from_json(json_str)
      obj = new
      obj.instance_variable_set(:@dirs, JSON.parse(json_str).transform_values { |files|
        files.map { |f| Entry.new(rel_path: f['path'], sha256: f['sha256'], mtime: f['mtime'], size: f['size']) }
      })
      obj
    end

    private

    def scan_dir(root)
      return [] unless File.directory?(root)
      entries = []
      Dir.glob("#{root}/**/*", File::FNM_DOTMATCH).sort.each do |abs|
        next if File.directory?(abs)
        next if abs.include?('/.git/')
        rel = abs.delete_prefix("#{root}/")
        stat = File.stat(abs)
        entries << Entry.new(
          rel_path: rel,
          sha256:   Digest::SHA256.file(abs).hexdigest,
          mtime:    stat.mtime.to_f,
          size:     stat.size
        )
      rescue Errno::EACCES, Errno::ENOENT => e
        warn "sink: skipping #{abs}: #{e.message}"
      end
      entries
    end
  end
end
