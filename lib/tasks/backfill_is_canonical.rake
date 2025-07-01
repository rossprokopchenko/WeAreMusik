
namespace :musicbrainz do
  desc "Mark all tracks as canonical in batches if their release is in canonical_musicbrainz_data"
  task mark_canonical_tracks: :environment do
    puts "Starting to mark tracks as canonical (streamed batches)..."

    start_time = Time.now
    batch_size = ENV.fetch('BATCH_SIZE', 50_000).to_i

    Track
      .joins(medium: :release)
      .joins("JOIN canonical_musicbrainz_data ON canonical_musicbrainz_data.release_mbid::uuid = release.gid")
      .where(is_canonical: false)
      .select(:id)
      .distinct
      .find_in_batches(batch_size: batch_size)
      .with_index do |batch, index|
        batch_ids = batch.map(&:id)
        Track.where(id: batch_ids).update_all(is_canonical: true)

        puts "Batch ##{index + 1}: Updated #{batch_ids.size} tracks..."
      end

    elapsed = Time.now - start_time
    puts "Finished marking tracks as canonical!"
    puts "Elapsed time: #{elapsed.round(2)} seconds"
  end

  desc "Mark all releases as canonical in batches if their MBID is in canonical_musicbrainz_data"
  task mark_canonical_releases: :environment do
    puts "Starting to mark releases as canonical (streamed batches)..."

    start_time = Time.now
    batch_size = ENV.fetch('BATCH_SIZE', 50_000).to_i

    Release
      .joins("JOIN canonical_musicbrainz_data ON canonical_musicbrainz_data.release_mbid::uuid = release.gid")
      .where(is_canonical: false)
      .select(:id)
      .distinct
      .find_in_batches(batch_size: batch_size)
      .with_index do |batch, index|

      batch_ids = batch.map(&:id)
      Release.where(id: batch_ids).update_all(is_canonical: true)

      puts "Batch ##{index + 1}: Updated #{batch_ids.size} releases..."
    end

    elapsed = Time.now - start_time
    puts "Finished marking releases as canonical!"
    puts "Elapsed time: #{elapsed.round(2)} seconds"
  end
end
