require 'net/http'
require 'json'
require 'uri'
require 'tempfile'
require 'open-uri'
require 'erb'

module MusicBrainzAPI
  module FetchWikimedia
    WIKIDATA_API_ENDPOINT = "https://musicbrainz.org/ws/2/artist/%{mbid}?inc=url-rels&fmt=json"
    WIKIDATA_ENTITY_ENDPOINT = "https://www.wikidata.org/wiki/Special:EntityData/%{wikidata_id}.json"
    COMMONS_FILE_URL = "https://commons.wikimedia.org/wiki/Special:FilePath/%{filename}"

    def self.fetch_or_cache_artist_image(artist)
      return nil unless artist.is_a?(Artist) && artist.gid.present?

      if artist.image.attached? && artist.image.persisted?
        Rails.logger.info "Serving cached artist image for Artist MBID: #{artist.gid}"
        return artist.image
      end

      wikidata_id = fetch_wikidata_id_from_mb(artist.gid)
      return nil unless wikidata_id

      filename = fetch_commons_filename_from_wikidata(wikidata_id)
      return nil unless filename

      image_url = COMMONS_FILE_URL % { filename: ERB::Util.url_encode(filename) }

      image = attach_image_from_url(artist, image_url)

      # Fetch author/credit info from Commons and save to artist
      author = fetch_commons_image_author(filename)
      if author.present? && artist.image_author != author
        artist.update(image_author: author)
      end

      puts "Author for image #{filename}: #{author}"

      image
    end

    private

    def self.fetch_commons_image_author(filename)
      url = "https://commons.wikimedia.org/w/api.php?action=query&titles=File:#{ERB::Util.url_encode(filename)}&prop=imageinfo&iiprop=extmetadata&format=json"
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      return nil unless response.is_a?(Net::HTTPSuccess)
    
      data = JSON.parse(response.body)
      pages = data.dig("query", "pages")
      return nil unless pages
    
      page = pages.values.first
      imageinfo = page.dig("imageinfo")
      return nil unless imageinfo&.any?
    
      extmetadata = imageinfo[0]["extmetadata"]
      author_html = extmetadata.dig("Artist", "value")
      return nil unless author_html
    
      # Strip HTML tags (author name is often inside an <a> tag)
      ActionView::Base.full_sanitizer.sanitize(author_html)
    rescue StandardError => e
      Rails.logger.error "Error fetching image metadata for #{filename}: #{e.message}"
      nil
    end

    # Step 1: Get Wikidata ID (e.g. Q11649) from MusicBrainz MBID via the MusicBrainz API
    def self.fetch_wikidata_id_from_mb(mbid)
      url = WIKIDATA_API_ENDPOINT % { mbid: mbid }
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "WeAreMusik/1.0.0 ( your@email.com )"

      response = http.request(request)


      puts "------- RESPONSE FROM WIKIDATA API: #{response.code} #{response.message} -------"

      return nil unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      
      puts "All relation types: #{data['relations'].map { |r| r['type'] }}"

      wikidata_rel = data.dig("relations")&.find { |r| r["type"] == "wikidata" }

      if wikidata_rel
        wikidata_url = wikidata_rel.dig("url", "resource")
        wikidata_url&.split('/')&.last # returns "Qxxxx"
      else
        Rails.logger.info "No Wikidata relation found for MBID #{mbid}"
        nil
      end


    rescue StandardError => e
      Rails.logger.error "Error fetching Wikidata ID for MBID #{mbid}: #{e.message}"
      nil
    end

    # Step 2: Given a Wikidata ID, get the Commons image filename (P18 property)
    def self.fetch_commons_filename_from_wikidata(wikidata_id)
      url = WIKIDATA_ENTITY_ENDPOINT % { wikidata_id: wikidata_id }
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)

      return nil unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      entities = data.dig("entities")
      entity = entities&.[](wikidata_id)
      claims = entity&.dig("claims")
      p18_claims = claims&.[]( "P18" )

      if p18_claims && p18_claims.any?
        # Return the value of the first P18 claim
        p18_claims[0].dig("mainsnak", "datavalue", "value")
      else
        Rails.logger.info "No Commons image (P18) found on Wikidata for entity #{wikidata_id}"
        nil
      end
    rescue StandardError => e
      Rails.logger.error "Error fetching Commons filename from Wikidata ID #{wikidata_id}: #{e.message}"
      nil
    end

    # Step 3: Download the image from Wikimedia Commons and attach it to the artist's ActiveStorage :image
    def self.attach_image_from_url(artist, url)
      Rails.logger.info "Downloading image from #{url}"
    
      file = URI.open(url) # this follows redirects
      # file.base_uri is the final resolved URI after redirects
    
      filename = File.basename(URI.parse(file.base_uri.to_s).path)
      
      artist.image.attach(
        io: file,
        filename: filename,
        content_type: file.content_type || 'application/octet-stream'
      )
    
      if artist.image.attached? && artist.image.persisted?
        Rails.logger.info "Successfully attached image to artist #{artist.gid}"
        artist.image
      else
        Rails.logger.error "Failed to attach image to artist #{artist.gid}"
        nil
      end
    rescue => e
      Rails.logger.error "Error downloading/attaching image: #{e.message}"
      nil
    end
    

    # Helper to follow HTTP redirects up to 5 times
    def self.follow_redirects(uri, limit = 5)
      raise ArgumentError, "HTTP redirect too deep" if limit == 0

      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPRedirection)
        location = response['location']
        Rails.logger.debug "Redirected from #{uri} to #{location}"
        follow_redirects(URI.parse(location), limit - 1)
      else
        uri
      end
    rescue StandardError => e
      Rails.logger.error "Error following redirect from #{uri}: #{e.message}"
      nil
    end
  end
end
