# app/integrations/wiki_media_tester.rb
require 'net/http'
require 'json'
require 'uri'
require 'open-uri'
require 'erb'

module WikiMediaAPI
  class Tester
    # Returns an array of { filename: ..., url: ..., author: ... } for a given artist MBID
    def self.fetch_all_artist_images(mbid)
      wikidata_id = FetchWikimedia.send(:fetch_wikidata_id_from_mb, mbid)
      return [] unless wikidata_id

      filenames = fetch_all_commons_filenames(wikidata_id)
      return [] if filenames.empty?

      filenames.map do |filename|
        {
          filename: filename,
          url: FetchWikimedia::COMMONS_FILE_URL % { filename: ERB::Util.url_encode(filename) },
          author: FetchWikimedia.send(:fetch_commons_image_author, filename)
        }
      end
    end

    private

    # Returns all P18 claims (all image filenames) for a Wikidata entity
    def self.fetch_all_commons_filenames(wikidata_id)
      url = FetchWikimedia::WIKIDATA_ENTITY_ENDPOINT % { wikidata_id: wikidata_id }
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      return [] unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      entities = data.dig("entities")
      entity = entities&.[](wikidata_id)
      claims = entity&.dig("claims")
      p18_claims = claims&.[]( "P18" ) || []

      p18_claims.map { |c| c.dig("mainsnak", "datavalue", "value") }.compact
    rescue => e
      Rails.logger.error "Error fetching all Commons filenames: #{e.message}"
      []
    end
  end
end
