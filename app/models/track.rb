class Track < ApplicationRecord
  include Meilisearch::Rails

  self.table_name = "musicbrainz.track"

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
  
  # Add delegation to access release_labels from release
  delegate :release_labels, to: :release, allow_nil: true

  # Validations
  validates :gid, presence: true
  validates :recording, presence: true
  validates :medium, presence: true
  validates :position, presence: true
  validates :number, presence: true
  validates :name, presence: true
  validates :artist_credit, presence: true

  meilisearch do
    # Define the attributes to be searched
    searchable_attributes %i[name artist_names release_title]

    # Define attributes that can be used for filtering
    filterable_attributes %i[medium_format_id is_canonical]

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

    add_attribute :is_canonical do
      is_canonical
    end
  end

  def track_number
    self.number
  end

  def release_group
    self.release&.release_group
  end

end
