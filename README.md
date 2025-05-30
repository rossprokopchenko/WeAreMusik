# WeAreMusic introduction

A web application developed in Ruby on Rails which is an interface for select MusicBrainz database archives. Designed for people to find new music. Uses Python machine learning to find correlations between track data and recommends users tracks. WeAreMusik has a social aspect where users can create their own profiles and leave comments on artists / albums / tracks.

## How to start using WeAreMusik

At the point of writing this, the application is not hosted and is not publicly available.

## Development

### Pre-requisites

* Ruby 3.4.3

* Rails 8.0.2

* Python 3.12.3

* PostgreSQL 16

* Docker (latest)

### Loading the MusicBrainz database

- Download the MusicBrainz mbdump archive which contains track, artist, release (album), and other data
https://metabrainz.org/datasets/download

- Create the following tables by following this schema:
    - track
    - artist
    - artist_credit
    - artist_credit_name
    - release
    - release_status
    - release_group
    - release_group_primary_type
    - recording
    - medium
    - medium_format
    
https://musicbrainz.org/doc/MusicBrainz_Database/Schema 

- Use the following script in the PSQL console to load in the files into the created database tables:
<code>\copy [table_name] FROM '/some/path/[table_name]' WITH (FORMAT text, DELIMITER E'\t', NULL '\N');</code>

- Implement gin indexing for faster query times:

<code>
UPDATE track t
SET search_vector = to_tsvector(
    'english',
    -- Concatenate track name, artist name, AND album name
    COALESCE(t.name, '') || ' ' ||
    COALESCE(ac.name, '') || ' ' ||
    COALESCE(r.name, '')
)
FROM artist_credit ac, medium m, release r -- Join to medium and release tables
WHERE t.artist_credit = ac.id
  AND t.medium = m.id      -- Join track to medium
  AND m.release = r.id;    -- Join medium to release
</code>

- Create the trigger function to update the track search vector for each new addition to the track table:

<code>
CREATE OR REPLACE FUNCTION update_track_search_vector() RETURNS TRIGGER AS $$
DECLARE
    artist_name_text TEXT;
    album_name_text TEXT;
BEGIN
    SELECT name INTO artist_name_text FROM artist_credit WHERE id = NEW.artist_credit;

    SELECT r.name INTO album_name_text
    FROM medium m
    JOIN release r ON m.release = r.id
    WHERE m.id = NEW.medium; -- Link via the new track's medium ID

    NEW.search_vector = to_tsvector(
        'english',
        COALESCE(NEW.name, '') || ' ' ||
        COALESCE(artist_name_text, '') || ' ' ||
        COALESCE(album_name_text, '')
    );
    RETURN NEW;
END;
</code>

- Use Docker to run Meilisearch:

<code>
docker run -it --rm \
    -p 7700:7700 \
    -v $(pwd)/meili_data:/meili_data \
    getmeili/meilisearch:latest \
    meilisearch --no-analytics --master-key ''
</code>

- With Meilisearch running - reindex Meilisearch:

<code>
bin/rails meilisearch:reindex
</code>