# WeAreMusik introduction

A web application developed in Ruby on Rails which uses the MusicBrainz music encyclopedia, machine learning and its users to recommend music. The project uses Python and machine learning to find correlations between track data and recommends users tracks.

## How to start using WeAreMusik

Visit [WeAreMusik.com](https://wearemusik.com/)

## Development

### Pre-requisites

* Ruby 3.4.3

* Rails 8.0.2

* Python 3.12.3

* PostgreSQL 16

* Docker (latest)

### MusicBrainz Server

https://github.com/metabrainz/musicbrainz-server

- Load [canonical data](https://metabrainz.org/datasets/derived-dumps#canonical)

<code>
    bin/rails tracks:mark_canonical_releases
</code>

<code>
    bin/rails releases:mark_canonical_releases
</code>

### Run ActiveRecods migrations

<code>
    bin/rails db:migrate
</code>

### Meilisearch

https://www.meilisearch.com/docs/learn/self_hosted/getting_started_with_self_hosted_meilisearch

<code>
    bin/rails meilisearch:reindex
</code>