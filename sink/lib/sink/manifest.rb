# frozen_string_literal: true

require 'digest'
require 'json'
require 'fileutils'

module Sink
  class Manifest
    Entry     = Struct.new(:rel_path, :sha256, :mtime, :size, keyword_init: true)
    Tombstone = Struct.new(:rel_path, :deleted_at, keyword_init: true)

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
        @tombstones[name] = detect_and_load_tombstones(name, @dirs[name])
      end
      self
    end

    def to_json(*)
      JSON.generate(
        @dirs.each_with_object({}) do |(name, entries), h|
          h[name] = {
            'files'      => entries.map { |e|
              { 'path' => e.rel_path, 'sha256' => e.sha256, 'mtime' => e.mtime, 'size' => e.size }
            },
            'tombstones' => (@tombstones[name] || []).map { |t|
              { 'path' => t.rel_path, 'deleted_at' => t.deleted_at }
            }
          }
        end
      )
    end

    def self.from_json(json_str)
      obj    = new
      parsed = JSON.parse(json_str)
      parsed.each do |name, data|
        if data.is_a?(Array)
          # legacy format (no tombstone support)
          obj.dirs[name]       = data.map { |f| Entry.new(rel_path: f['path'], sha256: f['sha256'], mtime: f['mtime'], size: f['size']) }
          obj.tombstones[name] = []
        else
          obj.dirs[name]       = (data['files'] || []).map { |f|
            Entry.new(rel_path: f['path'], sha256: f['sha256'], mtime: f['mtime'], size: f['size'])
          }
          obj.tombstones[name] = (data['tombstones'] || []).map { |t|
            Tombstone.new(rel_path: t['path'], deleted_at: t['deleted_at'])
          }
        end
      end
      obj
    end

    def self.record_tombstone(state_dir, dir_name, rel_path, deleted_at)
      path  = tombstone_path_for(state_dir, dir_name)
      tombs = load_tombstones_file(path)
      return if (existing = tombs[rel_path]) && existing >= deleted_at

      tombs[rel_path] = deleted_at
      FileUtils.mkdir_p(state_dir)
      File.write(path, JSON.generate(tombs))
    rescue => e
      warn "sink: failed to record tombstone: #{e.message}"
    end

    def self.tombstone_path_for(state_dir, dir_name) = File.join(state_dir, "#{dir_name}.tombstones.json")

    def self.load_tombstones_file(path)
      File.exist?(path) ? JSON.parse(File.read(path)) : {}
    rescue
      {}
    end

    private

    def detect_and_load_tombstones(dir_name, current_entries)
      return [] unless @state_dir

      current_paths = current_entries.map(&:rel_path).to_set
      tombs         = load_tombstones(dir_name)
      now           = Time.now.to_f

      load_previous_state(dir_name).each do |prev|
        next if current_paths.include?(prev.rel_path)
        tombs[prev.rel_path] ||= now
      end

      save_previous_state(dir_name, current_entries)
      save_tombstones_hash(dir_name, tombs)

      tombs.map { |path, ts| Tombstone.new(rel_path: path, deleted_at: ts) }
    end

    def load_tombstones(dir_name)
      self.class.load_tombstones_file(tombstone_path(dir_name))
    end

    def save_tombstones_hash(dir_name, hash)
      FileUtils.mkdir_p(@state_dir)
      File.write(tombstone_path(dir_name), JSON.generate(hash))
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

    def tombstone_path(dir_name) = self.class.tombstone_path_for(@state_dir, dir_name)
    def state_path(dir_name)     = File.join(@state_dir, "#{dir_name}.state.json")

    def scan_dir(root)
      return [] unless File.directory?(root)
      entries = []
      Dir.glob("#{root}/**/*", File::FNM_DOTMATCH).sort.each do |abs|
        next if File.directory?(abs)
        next if abs.include?('/.git/')
        rel  = abs.delete_prefix("#{root}/")
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
