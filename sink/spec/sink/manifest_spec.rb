# frozen_string_literal: true

RSpec.describe Sink::Manifest do
  around do |example|
    Dir.mktmpdir('sink-root') do |root|
      Dir.mktmpdir('sink-state') do |state_dir|
        @root       = root
        @state_dir  = state_dir
        example.run
      end
    end
  end

  def write_file(rel_path, content = 'hello', mtime: nil)
    abs = File.join(@root, rel_path)
    FileUtils.mkdir_p(File.dirname(abs))
    File.write(abs, content)
    File.utime(mtime, mtime, abs) if mtime
  end

  def scan
    Sink::Manifest.new({ 'notes' => @root }, @state_dir).scan
  end

  describe '#scan' do
    context 'when the sync dir has regular files' do
      it 'lists each file with its sha256, mtime, and size' do
        write_file('a.txt', 'hello')

        entry = scan.dirs['notes'].first

        expect(entry.rel_path).to eq('a.txt')
        expect(entry.sha256).to eq(Digest::SHA256.hexdigest('hello'))
        expect(entry.size).to eq(5)
      end
    end

    context 'when a file present in a previous scan has since been deleted from disk' do
      it 'records a tombstone for it that later scans still report' do
        write_file('a.txt')
        scan # establishes the previous-state snapshot

        File.delete(File.join(@root, 'a.txt'))

        after_delete = scan
        later        = scan

        expect(after_delete.tombstones['notes'].map(&:rel_path)).to eq(['a.txt'])
        expect(later.tombstones['notes'].map(&:rel_path)).to eq(['a.txt'])
      end
    end

    context 'when a tombstone was recorded for the dir before any scan' do
      it 'includes it in tombstones' do
        Sink::Manifest.record_tombstone(@state_dir, 'notes', 'old.txt', 123.0)

        expect(scan.tombstones['notes']).to eq([Sink::Manifest::Tombstone.new(rel_path: 'old.txt', deleted_at: 123.0)])
      end
    end
  end

  describe '.to_json / .from_json' do
    it 'round-trips file entries and tombstones' do
      write_file('a.txt', 'hello')
      write_file('b.txt')
      scan # establishes the previous-state snapshot
      File.delete(File.join(@root, 'b.txt'))

      round_tripped = Sink::Manifest.from_json(scan.to_json)

      expect(round_tripped.dirs['notes'].map(&:rel_path)).to eq(['a.txt'])
      expect(round_tripped.tombstones['notes'].map(&:rel_path)).to eq(['b.txt'])
    end
  end
end
