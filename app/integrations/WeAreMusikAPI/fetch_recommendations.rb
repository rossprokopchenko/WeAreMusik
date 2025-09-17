require "net/http"
require "uri"
require "json"

module WeAreMusikAPI
  class FetchRecommendations
    def self.fetch_similar_artists(artist_mbid, limit: 10)
      base_url = Rails.application.credentials.dig(:wearemusik, :api)
      raise "Python API base_url not set in credentials" unless base_url

      uri = URI("#{base_url}/recommend/")
      uri.query = URI.encode_www_form({ artist_mbid: artist_mbid, limit: limit })

      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error("FetchRecommendations error: #{response.code} - #{response.body}")
        return []
      end

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError => e
        Rails.logger.error("Failed to parse recommendations: #{e.message}")
        []
      end
    end
  end
end
