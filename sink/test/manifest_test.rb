# frozen_string_literal: true

require_relative 'test_helper'

class ManifestDeltaTest < Minitest::Test
  def test_first_scan_reports_all_files_as_added
    with_tmp_sync_dir do |root|
      File.write(File.join(root, 'a.txt'), 'hello')

      with_tmp_state_dir do |state_dir|
        manifest = Sink::Manifest.new({ 'notes' => root }, state_dir).scan

        delta = manifest.deltas['notes']
        assert_equal ['a.txt'], delta.added.map(&:rel_path)
        assert_empty delta.changed
        assert_empty delta.removed
        assert_empty manifest.tombstones['notes']
      end
    end
  end

  def test_unchanged_file_is_not_reported_in_added_or_changed
    with_tmp_sync_dir do |root|
      File.write(File.join(root, 'a.txt'), 'hello')

      with_tmp_state_dir do |state_dir|
        Sink::Manifest.new({ 'notes' => root }, state_dir).scan

        delta = Sink::Manifest.new({ 'notes' => root }, state_dir).scan.deltas['notes']
        assert_empty delta.added
        assert_empty delta.changed
      end
    end
  end

  def test_modified_file_is_reported_as_changed_not_added
    with_tmp_sync_dir do |root|
      path = File.join(root, 'a.txt')
      File.write(path, 'hello')

      with_tmp_state_dir do |state_dir|
        Sink::Manifest.new({ 'notes' => root }, state_dir).scan

        File.write(path, 'goodbye')
        delta = Sink::Manifest.new({ 'notes' => root }, state_dir).scan.deltas['notes']

        assert_empty delta.added
        assert_equal ['a.txt'], delta.changed.map(&:rel_path)
      end
    end
  end

  def test_deleted_file_is_reported_as_removed_and_tombstoned
    with_tmp_sync_dir do |root|
      path = File.join(root, 'a.txt')
      File.write(path, 'hello')

      with_tmp_state_dir do |state_dir|
        Sink::Manifest.new({ 'notes' => root }, state_dir).scan

        File.delete(path)
        manifest = Sink::Manifest.new({ 'notes' => root }, state_dir).scan

        assert_equal ['a.txt'], manifest.deltas['notes'].removed
        assert_equal ['a.txt'], manifest.tombstones['notes'].map(&:rel_path)
      end
    end
  end

  def test_deletion_already_tombstoned_is_not_reported_again_and_does_not_bump_timestamp
    with_tmp_sync_dir do |root|
      path = File.join(root, 'a.txt')
      File.write(path, 'hello')

      with_tmp_state_dir do |state_dir|
        Sink::Manifest.new({ 'notes' => root }, state_dir).scan
        File.delete(path)
        Sink::Manifest.new({ 'notes' => root }, state_dir).scan
        first_tombstone = Sink::Manifest.new({ 'notes' => root }, state_dir).scan.tombstones['notes'].first

        manifest = Sink::Manifest.new({ 'notes' => root }, state_dir).scan

        assert_empty manifest.deltas['notes'].removed
        assert_equal first_tombstone.deleted_at, manifest.tombstones['notes'].first.deleted_at
      end
    end
  end
end
