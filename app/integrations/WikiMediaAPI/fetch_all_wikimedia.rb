module WikiMediaAPI
  module FetchAllWikimedia
    WIKIDATA_API_ENDPOINT = "https://musicbrainz.org/ws/2/artist/%{mbid}?inc=url-rels&fmt=json"
    WIKIDATA_ENTITY_ENDPOINT = "https://www.wikidata.org/wiki/Special:EntityData/%{wikidata_id}.json"
    COMMONS_FILE_URL = "https://commons.wikimedia.org/wiki/Special:FilePath/%{filename}"

    # Fetch all images for an artist MBID
    def self.fetch_all_artist_images(artist)
      return [] unless artist.is_a?(Artist) && artist.gid.present?

      wikidata_id = fetch_wikidata_id_from_mb(artist.gid)
      return [] unless wikidata_id

      filenames = fetch_commons_filenames_from_wikidata(wikidata_id)
      return [] if filenames.empty?

      filenames.map do |filename|
        url = COMMONS_FILE_URL % { filename: ERB::Util.url_encode(filename) }
        { filename: filename, url: url, author: fetch_commons_image_author(filename) }
      end
    end

    private

    def self.fetch_commons_filenames_from_wikidata(wikidata_id)
      url = WIKIDATA_ENTITY_ENDPOINT % { wikidata_id: wikidata_id }
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      return [] unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      entity = data.dig("entities", wikidata_id)
      claims = entity&.dig("claims")
      p18_claims = claims&.[]("P18") || []

      p18_claims.map { |claim| claim.dig("mainsnak", "datavalue", "value") }.compact
    rescue StandardError => e
      Rails.logger.error "Error fetching Commons filenames from Wikidata ID #{wikidata_id}: #{e.message}"
      []
    end

    def self.fetch_commons_image_author(filename)
      url = "https://commons.wikimedia.org/w/api.php?action=query&titles=File:#{ERB::Util.url_encode(filename)}&prop=imageinfo&iiprop=extmetadata&format=json"
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      return nil unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      pages = data.dig("query", "pages")
      page = pages.values.first
      extmetadata = page.dig("imageinfo", 0, "extmetadata")
      author_html = extmetadata.dig("Artist", "value")
      ActionView::Base.full_sanitizer.sanitize(author_html) if author_html
    rescue StandardError => e
      Rails.logger.error "Error fetching author for image #{filename}: #{e.message}"
      nil
    end

    def self.fetch_wikidata_id_from_mb(mbid)
      url = WIKIDATA_API_ENDPOINT % { mbid: mbid }
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "WeAreMusik/1.0.0 (your@email.com)"
      response = http.request(request)
      return nil unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      wikidata_rel = data.dig("relations")&.find { |r| r["type"] == "wikidata" }
      wikidata_rel&.dig("url", "resource")&.split('/')&.last
    rescue StandardError => e
      Rails.logger.error "Error fetching Wikidata ID for MBID #{mbid}: #{e.message}"
      nil
    end
  end
end
