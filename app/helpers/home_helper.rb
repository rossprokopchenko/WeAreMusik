module HomeHelper
  
  def dom_id_input_tracks
    if @input_tracks.empty?
      puts "Input tracks dom id: input_tracks_empty"

      return "input_tracks_empty"
    else
      puts "Input tracks dom id: #{@input_tracks.map(&:track_id).join('_')}"

      return "input_tracks_#{@input_tracks.map(&:track_id).join('_')}"
    end
  end

  def dom_id_search_result_tracks
    if @search_result_tracks.empty?
      puts "Search result tracks dom id: search_result_tracks_empty"

      return "search_result_tracks_empty"
    else
      puts "Search result tracks dom id: #{@search_result_tracks.map(&:track_id).join('_')}"

      return "search_result_tracks_#{@search_result_tracks.map(&:track_id).join('_')}"
    end
  end

  def dom_id_recommended_tracks
    if @recommended_tracks.empty?
      puts "Recommended tracks dom id: recommended_tracks_empty"
      
      return "recommended_tracks_empty"
    else
      puts "Recommended tracks dom id: #{@recommended_tracks.map(&:track_id).join('_')}"

      return "recommended_tracks_#{@recommended_tracks.map(&:track_id).join('_')}"
    end
  end
    
end