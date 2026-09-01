# frozen_string_literal: true

require 'digest'
require 'json'
require 'fileutils'

module Sink
  class Manifest
    Entry     = Struct.new(:rel_path, :sha256, :mtime, :size, keyword_init: true)
    Tombstone = Struct.new(:rel_path, :deleted_at, keyword_init: true)
    Delta     = Struct.new(:added, :changed, :removed, keyword_init: true)

    attr_reader :dirs, :tombstones, :deltas

    def initialize(sync_dirs = {}, state_dir = nil)
      @sync_dirs  = sync_dirs
      @state_dir  = state_dir
      @dirs       = {}
      @tombstones = {}
      @deltas     = {}
    end

    def scan
      @sync_dirs.each do |name, root|
        @dirs[name]                        = scan_dir(root)
        @tombstones[name], @deltas[name]   = detect_changes(name, @dirs[name])
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
      with_lock(state_dir, dir_name) do
        path  = tombstone_path_for(state_dir, dir_name)
        tombs = load_tombstones_file(path)
        next if (existing = tombs[rel_path]) && existing >= deleted_at

        tombs[rel_path] = deleted_at
        File.write(path, JSON.generate(tombs))
      end
    rescue => e
      warn "sink: failed to record tombstone: #{e.message}"
    end

    def self.tombstone_path_for(state_dir, dir_name) = File.join(state_dir, "#{dir_name}.tombstones.json")
    def self.state_path_for(state_dir, dir_name)     = File.join(state_dir, "#{dir_name}.state.json")

    def self.load_tombstones_file(path)
      File.exist?(path) ? JSON.parse(File.read(path)) : {}
    rescue
      {}
    end

    def self.update_state_entry(state_dir, dir_name, entry)
      with_lock(state_dir, dir_name) do
        path    = state_path_for(state_dir, dir_name)
        entries = load_state_file(path)
        entries[entry.rel_path] = { 'path' => entry.rel_path, 'sha256' => entry.sha256, 'mtime' => entry.mtime, 'size' => entry.size }
        File.write(path, JSON.generate(entries.values))
      end
    rescue => e
      warn "sink: failed to update state entry: #{e.message}"
    end

    def self.remove_state_entry(state_dir, dir_name, rel_path)
      with_lock(state_dir, dir_name) do
        path    = state_path_for(state_dir, dir_name)
        entries = load_state_file(path)
        entries.delete(rel_path)
        File.write(path, JSON.generate(entries.values))
      end
    rescue => e
      warn "sink: failed to remove state entry: #{e.message}"
    end

    def self.load_state_file(path)
      return {} unless File.exist?(path)
      JSON.parse(File.read(path)).each_with_object({}) { |f, h| h[f['path']] = f }
    rescue
      {}
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

    def detect_changes(dir_name, current_entries)
      return [[], Delta.new(added: [], changed: [], removed: [])] unless @state_dir

      current_index = current_entries.each_with_object({}) { |e, h| h[e.rel_path] = e }
      now           = Time.now.to_f
      added         = []
      changed       = []
      removed       = []
      tombs         = nil

      self.class.with_lock(@state_dir, dir_name) do
        tombs          = load_tombstones(dir_name)
        previous_index = load_previous_state(dir_name).each_with_object({}) { |e, h| h[e.rel_path] = e }

        previous_index.each_key do |rel_path|
          next if current_index.key?(rel_path)
          next if tombs.key?(rel_path)
          tombs[rel_path] = now
          removed << rel_path
        end

        current_index.each do |rel_path, entry|
          prev = previous_index[rel_path]
          added << entry if prev.nil?
          changed << entry if prev && prev.sha256 != entry.sha256
        end

        save_previous_state(dir_name, current_entries)
        save_tombstones_hash(dir_name, tombs)
      end

      [tombs.map { |path, ts| Tombstone.new(rel_path: path, deleted_at: ts) },
       Delta.new(added: added, changed: changed, removed: removed)]
    end

    def load_tombstones(dir_name)
      self.class.load_tombstones_file(tombstone_path(dir_name))
    end

    def save_tombstones_hash(dir_name, hash)
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
    def state_path(dir_name)     = self.class.state_path_for(@state_dir, dir_name)

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
