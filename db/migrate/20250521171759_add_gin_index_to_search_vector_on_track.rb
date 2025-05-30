class AddGinIndexToSearchVectorOnTrack < ActiveRecord::Migration[8.0]
  # disable_ddl_transaction!  # batches commit independently

  # BATCH_SIZE = 100_000

  def up
    # min_id = select_value("SELECT MIN(id) FROM track").to_i
    # max_id = select_value("SELECT MAX(id) FROM track").to_i
    # total = max_id - min_id + 1

    # (min_id..max_id).step(BATCH_SIZE) do |start_id|
    #   end_id = start_id + BATCH_SIZE - 1

    #   say_with_time "Updating search_vector for tracks id #{start_id} to #{end_id}" do
    #     execute <<~SQL.squish
    #       UPDATE track
    #       SET search_vector = to_tsvector('simple',
    #         coalesce(track.name, '') || ' ' ||
    #         coalesce(recording.name, '') || ' ' ||
    #         coalesce(artist_credit.name, '')
    #       )
    #       FROM recording, artist_credit
    #       WHERE track.recording = recording.id
    #         AND track.artist_credit = artist_credit.id
    #         AND track.id BETWEEN #{start_id} AND #{end_id};
    #     SQL
    #   end

    #   # Progress check:
    #   # populated_count = select_value("SELECT COUNT(*) FROM track WHERE search_vector IS NOT NULL").to_i
    #   # percent_done = (populated_count.to_f / total * 100).round(2)
    #   # say "Progress: #{populated_count} / #{total} tracks updated (#{percent_done}%)"
    # end
  end

  def down
    execute "UPDATE track SET search_vector = NULL"
  end
end
