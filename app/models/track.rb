class Track < ApplicationRecord

  self.table_name = "track"

  include Meilisearch::Rails

  meilisearch do
    # Define the attributes to be searched
    searchable_attributes %i[name artist_names release_title]

    # Define attributes that can be used for filtering
    filterable_attributes %i[medium_format_id]

    # Define attributes that can be used for sorting.
    # Useful for sorting by relevance, name, length, etc.
    sortable_attributes %i[name artist_names release_title]

    # Attributes to display in search results.
    displayed_attributes %i[id name artist_names release_title]

    # Add custom attributes from associations.
    # These methods will be called for each Track record during indexing.
    add_attribute :artist_names do
      artist_credit.artists.map(&:name).join(', ') if artist_credit&.artists.present?
    end

    add_attribute :release_title do
      release.name if release.present? # Access through delegation to medium -> release
    end

    add_attribute :medium_format_id do
      medium.format.id if medium&.format.present? # Access through medium -> format
    end
  end

  def track_number
    self.number
  end

  # def self.search(query)
  #   # Ensure query is not empty to avoid errors with to_tsquery
  #   return none if query.blank?

  #   # Process the query to use '&' for AND logic as required by tsquery
  #   # This will turn "rise against savior" into "'rise' & 'against' & 'savior'"
  #   # which is what PostgreSQL's to_tsquery expects.
  #   # IMPORTANT: Sanitize user input to prevent SQL injection or tsquery syntax errors.
  #   # This is a basic example; consider a more robust sanitization if needed.
  #   sanitized_query_parts = query.split.map { |word| "'#{word.gsub("'", "''")}'" } # Escape single quotes within words
  #   tsquery_string = sanitized_query_parts.join(' & ')

  #   # Call the pg_search_scope with the processed tsquery string
  #   search_by_track_and_artist(tsquery_string)
  #     .includes(:artist_credit) # Eager load artist_credit for display
  # end

  # pg_search_scope :search_by_track_and_artist,
  #   # We set 'against' to nil or an empty array because we are directly using
  #   # our existing 'search_vector' column, which already contains the combined text.
  #   against: nil,
  #   using: {
  #     tsearch: {
  #       tsvector_column: 'search_vector',
  #       dictionary: 'english',
  #       prefix: true,
  #       any_word: false  # All words must match to reduce false positives
  #     }
  #   }

  # def self.multiple_column_search(query)
  #   # Ensure query is not empty to avoid issues with to_tsquery
  #   return none if query.blank?

  #   # Process the user's query into the 'tsquery' format
  #   # This will turn "rise against savior" into "'rise' & 'against' & 'savior'"
  #   # The .gsub("'", "''") part escapes single quotes within the words themselves.
  #   sanitized_query_parts = query.split.map { |word| "'#{word.gsub("'", "''")}'" }
  #   tsquery_string = sanitized_query_parts.join(' & ')

  #   # Call the pg_search_scope with the prepared tsquery string
  #   # The includes for display will be handled by the controller's chain.
  #   search_by_track_and_artist(tsquery_string)
  # end

  # Columns:
  # id            : integer, primary key
  # gid           : uuid, not null
  # recording     : integer, foreign key to recordings, not null
  # medium        : integer, foreign key to media, not null
  # position      : integer, not null (track position on medium)
  # number        : text, not null (track number label)
  # name          : text, not null (track title)
  # artist_credit : integer, foreign key, not null
  # length        : integer (track length in ms)
  # edits_pending : integer, default 0, not null
  # last_updated  : timestamp
  # is_data_track : boolean (nullable, indicates data track on CD)

  # Associations
  belongs_to :recording, foreign_key: :recording
  belongs_to :medium, foreign_key: :medium
  belongs_to :artist_credit, foreign_key: :artist_credit

  has_many :artist_credit_names, through: :artist_credit
  has_many :artists, through: :artist_credit_names

  # Delegations
  delegate :release, to: :medium, allow_nil: true
  delegate :artist_credit, to: :release, allow_nil: true

  # Validations
  validates :gid, presence: true
  validates :recording, presence: true
  validates :medium, presence: true
  validates :position, presence: true
  validates :number, presence: true
  validates :name, presence: true
  validates :artist_credit, presence: true

end
