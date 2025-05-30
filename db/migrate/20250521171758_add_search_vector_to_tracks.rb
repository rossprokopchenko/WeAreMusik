class AddSearchVectorToTracks < ActiveRecord::Migration[8.0]
  # disable_ddl_transaction!  # so batches can commit independently

  # BATCH_SIZE = 100_000

  def up
    # min_id = select_value("SELECT MIN(id) FROM track").to_i
    # max_id = select_value("SELECT MAX(id) FROM track").to_i

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
    # end
  end

  def down
    # optional: reset the search_vector to NULL or empty if you want to rollback
    execute "UPDATE track SET search_vector = NULL"
  end
end
