# lib/tasks/clean_tracks.rake

namespace :tracks do
  desc "Clean up artist formatting in tracks table"
  task clean_artists: :environment do
    batch_size = 10_000
    total = Track.count
    offset = 0

    while offset < total
      puts "Processing batch starting at offset #{offset}..."
      tracks = Track.limit(batch_size).offset(offset)

      updates = tracks.map do |track|
        cleaned_artists = track.artists.to_s.gsub(/[\[\]']/, '').gsub(/\s*,\s*/, ', ')
        { id: track.id, artists: cleaned_artists }
      end

      Track.upsert_all(updates, unique_by: :id) if updates.any?

      offset += batch_size
    end

    puts "🎉 Done cleaning artist names for #{total} tracks."
  end
end
