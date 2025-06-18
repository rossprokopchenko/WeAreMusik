
namespace :tracks do
  desc "Mark tracks as canonical if their release is in the canonical_musicbrainz_data table"
  task mark_canonical: :environment do
    puts "Loading canonical release MBIDs..."

    canonical_release_mbids = Set.new(
      ActiveRecord::Base.connection.exec_query("SELECT DISTINCT release_mbid FROM canonical_musicbrainz_data").rows.flatten
    )

    puts "Found #{canonical_release_mbids.size} canonical releases"

    batch_size = 10_000
    total_updated = 0

    Track.includes(medium: :release).find_in_batches(batch_size: batch_size) do |batch|
      updates = []

      batch.each do |track|
        release_gid = track.release&.gid
        next if release_gid.nil?

        if canonical_release_mbids.include?(release_gid)
          updates << track.id
        end
      end

      if updates.any?
        Track.where(id: updates).update_all(is_canonical: true)
        total_updated += updates.size
        puts "Updated #{updates.size} tracks in this batch (Total: #{total_updated})"
      end
    end

    puts "Finished. Total canonical tracks updated: #{total_updated}"
  end
end
