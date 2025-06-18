
require 'net/http'
require 'json'
require 'uri'
require 'tempfile'
require 'stringio'

module MusicBrainzAPI
  module FetchCaa
    # This is the primary method to call for fetching or getting cached cover art.
    # It attempts to find the front cover.
    #
    # Arguments:
    #   release: An instance of your Release model (which should have 'gid' for MBID and 'cover_art' attachment).
    # Returns:
    #   An ActiveStorage::Attached::One object (the image attachment) if successful, or nil.
    def self.fetch_or_cache_cover_art(release)
      # Using puts for debugging as you had it, but Rails.logger.info is generally preferred
      puts "Fetching cover art URLs for Release MBID: #{release.gid}"

      # Basic validation: ensure we have a valid Release record with a MusicBrainz ID (gid)
      unless release.is_a?(Release) && release.gid.present?
        Rails.logger.warn "Invalid record provided to fetch_or_cache_cover_art. Expected Release with gid."
        return nil
      end

      # 1. Check if the cover art is already attached and persisted in our storage
      if release.cover_art.attached? && release.cover_art.persisted?
        Rails.logger.info "Serving cached cover art for Release MBID: #{release.gid} from Active Storage."
        return release.cover_art # Return the Active Storage attachment
      end

      # 2. If not cached, fetch metadata from Cover Art Archive API
      Rails.logger.info "Cover art for Release MBID: #{release.gid} not found in cache. Fetching from CAA API."
      
      # IMPORTANT: Apply follow_redirects to the initial metadata lookup URI as well
      # This handles 307 (and other) redirects from coverartarchive.org itself
      initial_metadata_uri = URI.parse("https://coverartarchive.org/release/#{release.gid}/")
      final_metadata_uri = follow_redirects(initial_metadata_uri) || initial_metadata_uri
      
      # If follow_redirects returned nil due to an error, we can't proceed
      return nil unless final_metadata_uri

      cover_art_metadata = get_external_cover_art_urls(final_metadata_uri, release.gid) # Pass final_metadata_uri

      if cover_art_metadata.nil? || cover_art_metadata.empty?
        Rails.logger.info "No external cover art metadata found for Release MBID: #{release.gid} from CAA."
        return nil
      end

      # Try to find the front cover, otherwise take the first available image
      front_cover_info = cover_art_metadata.find { |img| img[:front] } || cover_art_metadata.first
      
      # Ensure we have a large_thumbnail_url to use
      unless front_cover_info && front_cover_info[:large_thumbnail_url].present?
        Rails.logger.warn "No usable large_thumbnail_url found in CAA metadata for MBID: #{release.gid}. Falling back to full_size_url if available."
        # Fallback to full_size_url if large_thumbnail_url is not present
        image_url = front_cover_info[:full_size_url] if front_cover_info && front_cover_info[:full_size_url].present?
        unless image_url.present?
            Rails.logger.warn "No full_size_url available either for MBID: #{release.gid}."
            return nil
        end
      else
        image_url = front_cover_info[:large_thumbnail_url]
      end

      # 3. Download the image data from the chosen URL and attach it
      begin
        image_uri = URI.parse(image_url)
        
        # Follow redirects to ensure we get the final image location (archive.org might redirect)
        final_image_uri = follow_redirects(image_uri) || image_uri
        
        # If follow_redirects returned nil due to an error, we can't proceed with download
        return nil unless final_image_uri

        response = Net::HTTP.get_response(final_image_uri)

        if response.is_a?(Net::HTTPSuccess)
          temp_file = Tempfile.new(
            [File.basename(final_image_uri.path), File.extname(final_image_uri.path)],
            Rails.root.join('tmp')
          )
          temp_file.binmode
          temp_file.write(response.body)
          temp_file.rewind

          release.cover_art.attach( # Using 'cover_art' as per your model's attachment name
            io: temp_file,
            filename: File.basename(final_image_uri.path),
            content_type: response['Content-Type'] || 'application/octet-stream'
          )

          if release.cover_art.attached? && release.cover_art.persisted?
            Rails.logger.info "Successfully downloaded and cached cover art for Release MBID: #{release.gid}"
            return release.cover_art
          else
            Rails.logger.error "Active Storage attachment failed for MBID #{release.gid} after download."
            return nil
          end
        else
          Rails.logger.warn "Failed to download image from #{image_url}. HTTP Status: #{response.code}"
          return nil
        end
      rescue StandardError => e
        Rails.logger.error "An error occurred during image download/attachment for MBID #{release.gid}: #{e.message}"
        return nil
      ensure
        temp_file.close if temp_file
        temp_file.unlink if temp_file
      end
    end

    private

    # Fetches basic cover art metadata (URLs) from the external Cover Art Archive API.
    # Now takes the final URI after redirects for robustness.
    # Returns an array of image info hashes, or nil if no data found/error.
    def self.get_external_cover_art_urls(final_metadata_uri, release_mbid) # Added release_mbid for logging
      begin
        response = Net::HTTP.get_response(final_metadata_uri)

        case response
        when Net::HTTPSuccess then
          data = JSON.parse(response.body)
          images = data['images']

          if images && !images.empty?
            images.map do |image|
              {
                id: image['id'],
                front: image['front'],
                back: image['back'],
                full_size_url: image['image'], # Keep full_size_url for fallback
                small_thumbnail_url: image['thumbnails']['small'],
                large_thumbnail_url: image['thumbnails']['large'],
              }
            end
          else
            Rails.logger.info "CAA: No 'images' array found in JSON for MBID: #{release_mbid}"
            nil
          end
        when Net::HTTPNotFound then
          Rails.logger.info "CAA: Cover art metadata (404 Not Found) for MBID: #{release_mbid}"
          nil
        else
          Rails.logger.error "CAA: HTTP Error #{response.code}: #{response.message} during external lookup for MBID: #{release_mbid}"
          nil
        end
      rescue JSON::ParserError => e
        Rails.logger.error "CAA: JSON parsing error for MBID #{release_mbid}: #{e.message}"
        nil
      rescue StandardError => e
        Rails.logger.error "CAA: An unexpected error occurred during external lookup for MBID #{release_mbid}: #{e.message}"
        nil
      end
    end

    # Helper method to follow HTTP redirects to get the final URI.
    def self.follow_redirects(uri, limit = 5)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0

      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPRedirection)
        location = response['location']
        Rails.logger.debug "Redirected from #{uri} to #{location}"
        # Recursively call with the new location and reduced limit
        follow_redirects(URI.parse(location), limit - 1)
      else
        uri # Return the final URI if not a redirect
      end
    rescue StandardError => e
      Rails.logger.error "Error following redirect from #{uri}: #{e.message}"
      nil # Return nil if error during redirect
    end
  end
end