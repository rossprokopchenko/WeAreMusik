class Release < MusicbrainzRecord
  include Meilisearch::Rails

  self.table_name = "musicbrainz.release"

  # Columns:
  # id              : integer, primary key
  # gid             : uuid, not null
  # name            : text, not null
  # artist_credit   : integer, not null (FK)
  # release_group   : integer, not null (FK)
  # status          : integer (FK to release_status)
  # packaging       : integer (FK to release_packaging)
  # language        : integer
  # script          : integer
  # barcode         : text
  # comment         : text
  # edits_pending   : integer, default 0, not null
  # quality         : integer
  # last_updated    : timestamp

  has_one_attached :cover_art

  has_one :first_release_date, class_name: "ReleaseFirstReleaseDate", foreign_key: "release"

  belongs_to :artist_credit, foreign_key: "artist_credit"
  belongs_to :release_group, foreign_key: "release_group"
  belongs_to :release_status, foreign_key: "status", optional: true
  belongs_to :release_packaging, foreign_key: "packaging", optional: true

  has_many :media, foreign_key: "release"
  has_many :tracks, through: :media

  has_many :release_labels, foreign_key: "release"
  has_many :release_countries, foreign_key: "release"

  # Through release_labels, a Release can have many Labels
  has_many :labels, through: :release_labels

  validates :gid, :name, presence: true

  meilisearch do
    searchable_attributes %i[name artist_names]

    # Define attributes that can be used for filtering
    filterable_attributes %i[ first_release_year is_canonical ]

    # Define attributes that can be used for sorting.
    # Useful for sorting by relevance, name, length, etc.
    sortable_attributes %i[name artist_names first_release_year]

    # Attributes to display in search results.
    displayed_attributes %i[id name artist_names]

    add_attribute :artist_names do
      artist_credit.artists.map(&:name).join(', ') if artist_credit&.artists.present?
    end

    add_attribute :first_release_year do
      first_release_date&.year
    end

    add_attribute :is_canonical do
      is_canonical
    end
  end
end
