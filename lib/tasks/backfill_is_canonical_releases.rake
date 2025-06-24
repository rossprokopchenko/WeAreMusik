
namespace :releases do
  desc "Mark releases as canonical if their MBID is in the canonical_musicbrainz_data table"
  task mark_canonical: :environment do
    puts "Loading canonical release MBIDs..."

    canonical_release_mbids = Set.new(
      ActiveRecord::Base.connection.exec_query("SELECT DISTINCT release_mbid FROM canonical_musicbrainz_data").rows.flatten
    )

    puts "Found #{canonical_release_mbids.size} canonical release MBIDs"

    batch_size = 10_000
    total_updated = 0

    Release.find_in_batches(batch_size: batch_size) do |batch|
      updates = []

      batch.each do |release|
        if canonical_release_mbids.include?(release.gid)
          updates << release.id
        end
      end

      if updates.any?
        Release.where(id: updates).update_all(is_canonical: true)
        total_updated += updates.size
        puts "Updated #{updates.size} releases in this batch (Total: #{total_updated})"
      end
    end

    puts "Finished. Total canonical releases updated: #{total_updated}"
  end
end