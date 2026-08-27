# frozen_string_literal: true

require 'digest'
require 'json'
require 'fileutils'

module Sink
  class Manifest
    Entry = Struct.new(:rel_path, :sha256, :mtime, :size, keyword_init: true)

    TOMBSTONE_FILENAME = '.sink-tombstones.json'

    attr_reader :dirs, :tombstones

    def initialize(sync_dirs = {}, state_dir = nil)
      @sync_dirs  = sync_dirs
      @state_dir  = state_dir
      @dirs       = {}
      @tombstones = {}
    end

    def scan
      @sync_dirs.each do |name, root|
        @dirs[name]       = scan_dir(root)
        @tombstones[name] = detect_and_persist_tombstones(name, root, @dirs[name])
      end
      self
    end

    def to_json(*)
      JSON.generate(
        @dirs.transform_values { |entries|
          entries.map { |e| { 'path' => e.rel_path, 'sha256' => e.sha256, 'mtime' => e.mtime, 'size' => e.size } }
        }
      )
    end

    def self.from_json(json_str)
      obj = new
      JSON.parse(json_str).each do |name, files|
        obj.dirs[name] = files.map { |f|
          Entry.new(rel_path: f['path'], sha256: f['sha256'], mtime: f['mtime'], size: f['size'])
        }
      end
      obj
    end

    def self.tombstone_path_for(root) = File.join(root, TOMBSTONE_FILENAME)

    def self.load_tombstones(root)
      path = tombstone_path_for(root)
      File.exist?(path) ? JSON.parse(File.read(path)) : {}
    rescue
      {}
    end

    def self.save_tombstones(root, hash)
      File.write(tombstone_path_for(root), JSON.generate(hash))
    end

    # Serializes access to a dir_name's state/tombstone files across threads
    # (the server handles peer requests concurrently) and across processes
    # (the periodic client runs as a separate process from the server), so a
    # read-modify-write here can never be clobbered by a concurrent one.
    def self.with_lock(state_dir, dir_name)
      FileUtils.mkdir_p(state_dir)
      File.open(File.join(state_dir, "#{dir_name}.lock"), File::CREAT | File::RDWR) do |f|
        f.flock(File::LOCK_EX)
        yield
      end
    end

    private

    def detect_and_persist_tombstones(dir_name, root, current_entries)
      return {} unless @state_dir

      current_paths = current_entries.map(&:rel_path).to_set
      now           = Time.now.to_f
      tombs         = nil

      self.class.with_lock(@state_dir, dir_name) do
        tombs = self.class.load_tombstones(root)

        load_previous_state(dir_name).each do |prev|
          next if current_paths.include?(prev.rel_path)
          tombs[prev.rel_path] = now
        end

        save_previous_state(dir_name, current_entries)
        self.class.save_tombstones(root, tombs)
      end

      tombs
    end

    def load_previous_state(dir_name)
      path = state_path(dir_name)
      return [] unless File.exist?(path)
      JSON.parse(File.read(path)).map { |f|
        Entry.new(rel_path: f['path'], sha256: f['sha256'], mtime: f['mtime'], size: f['size'])
      }
    rescue
      []
    end

    def save_previous_state(dir_name, entries)
      FileUtils.mkdir_p(@state_dir)
      File.write(state_path(dir_name), JSON.generate(
        entries.map { |e| { 'path' => e.rel_path, 'sha256' => e.sha256, 'mtime' => e.mtime, 'size' => e.size } }
      ))
    end

    def state_path(dir_name) = File.join(@state_dir, "#{dir_name}.state.json")

    def scan_dir(root)
      return [] unless File.directory?(root)
      entries = []
      Dir.glob("#{root}/**/*", File::FNM_DOTMATCH).sort.each do |abs|
        next if File.directory?(abs)
        next if abs.include?('/.git/')
        rel  = abs.delete_prefix("#{root}/")
        next if rel == TOMBSTONE_FILENAME
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
