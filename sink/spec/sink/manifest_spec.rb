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
    described_class.new({ 'notes' => @root }, @state_dir).scan
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

    context 'when the sync dir contains the hidden tombstone file' do
      it 'excludes it from the listed files' do
        write_file('a.txt')
        File.write(File.join(@root, Sink::Manifest::TOMBSTONE_FILENAME), '{}')

        expect(scan.dirs['notes'].map(&:rel_path)).to eq(['a.txt'])
      end
    end

    context 'when a file present in a previous scan has since been deleted from disk' do
      it 'records a tombstone for it and persists it to the hidden tombstone file in the sync dir' do
        write_file('a.txt')
        scan # establishes the previous-state snapshot

        File.delete(File.join(@root, 'a.txt'))
        result = scan

        expect(result.tombstones['notes']).to have_key('a.txt')

        on_disk = JSON.parse(File.read(File.join(@root, Sink::Manifest::TOMBSTONE_FILENAME)))
        expect(on_disk).to have_key('a.txt')
      end
    end

    context 'when the hidden tombstone file already has entries on disk' do
      it 'loads them into tombstones without needing a prior scan' do
        File.write(File.join(@root, Sink::Manifest::TOMBSTONE_FILENAME), JSON.generate('old.txt' => 123.0))

        expect(scan.tombstones['notes']).to eq('old.txt' => 123.0)
      end
    end
  end

  describe '.to_json / .from_json' do
    it 'round-trips file entries without carrying tombstones over the wire' do
      write_file('a.txt', 'hello')

      round_tripped = described_class.from_json(scan.to_json)

      expect(round_tripped.dirs['notes'].map(&:rel_path)).to eq(['a.txt'])
    end
  end
end
