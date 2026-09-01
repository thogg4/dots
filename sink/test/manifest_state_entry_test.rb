# frozen_string_literal: true

require_relative 'test_helper'

class ManifestStateEntryTest < Minitest::Test
  def test_update_state_entry_adds_a_new_entry_to_an_empty_state_file
    with_tmp_state_dir do |state_dir|
      entry = Sink::Manifest::Entry.new(rel_path: 'a.txt', sha256: 'abc', mtime: 1.0, size: 5)
      Sink::Manifest.update_state_entry(state_dir, 'notes', entry)

      saved = JSON.parse(File.read(File.join(state_dir, 'notes.state.json')))
      assert_equal [{ 'path' => 'a.txt', 'sha256' => 'abc', 'mtime' => 1.0, 'size' => 5 }], saved
    end
  end

  def test_update_state_entry_overwrites_an_existing_entry_with_the_same_path
    with_tmp_state_dir do |state_dir|
      original = Sink::Manifest::Entry.new(rel_path: 'a.txt', sha256: 'abc', mtime: 1.0, size: 5)
      updated  = Sink::Manifest::Entry.new(rel_path: 'a.txt', sha256: 'def', mtime: 2.0, size: 9)
      Sink::Manifest.update_state_entry(state_dir, 'notes', original)
      Sink::Manifest.update_state_entry(state_dir, 'notes', updated)

      saved = JSON.parse(File.read(File.join(state_dir, 'notes.state.json')))
      assert_equal [{ 'path' => 'a.txt', 'sha256' => 'def', 'mtime' => 2.0, 'size' => 9 }], saved
    end
  end

  def test_update_state_entry_leaves_other_entries_untouched
    with_tmp_state_dir do |state_dir|
      a = Sink::Manifest::Entry.new(rel_path: 'a.txt', sha256: 'abc', mtime: 1.0, size: 5)
      b = Sink::Manifest::Entry.new(rel_path: 'b.txt', sha256: 'xyz', mtime: 3.0, size: 7)
      Sink::Manifest.update_state_entry(state_dir, 'notes', a)
      Sink::Manifest.update_state_entry(state_dir, 'notes', b)

      saved = JSON.parse(File.read(File.join(state_dir, 'notes.state.json')))
      assert_equal %w[a.txt b.txt], saved.map { |e| e['path'] }.sort
    end
  end

  def test_remove_state_entry_removes_only_the_named_path
    with_tmp_state_dir do |state_dir|
      a = Sink::Manifest::Entry.new(rel_path: 'a.txt', sha256: 'abc', mtime: 1.0, size: 5)
      b = Sink::Manifest::Entry.new(rel_path: 'b.txt', sha256: 'xyz', mtime: 3.0, size: 7)
      Sink::Manifest.update_state_entry(state_dir, 'notes', a)
      Sink::Manifest.update_state_entry(state_dir, 'notes', b)

      Sink::Manifest.remove_state_entry(state_dir, 'notes', 'a.txt')

      saved = JSON.parse(File.read(File.join(state_dir, 'notes.state.json')))
      assert_equal ['b.txt'], saved.map { |e| e['path'] }
    end
  end

  def test_a_file_written_via_update_state_entry_is_seen_as_unchanged_on_next_scan
    with_tmp_sync_dir do |root|
      path = File.join(root, 'a.txt')
      File.write(path, 'hello')
      sha256 = Digest::SHA256.file(path).hexdigest
      mtime  = File.mtime(path).to_f

      with_tmp_state_dir do |state_dir|
        entry = Sink::Manifest::Entry.new(rel_path: 'a.txt', sha256: sha256, mtime: mtime, size: 5)
        Sink::Manifest.update_state_entry(state_dir, 'notes', entry)

        delta = Sink::Manifest.new({ 'notes' => root }, state_dir).scan.deltas['notes']
        assert_empty delta.added
        assert_empty delta.changed
      end
    end
  end
end
