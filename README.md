# WeAreMusik introduction

WeAreMusik is a web app built with Ruby on Rails that uses MusicBrainz, Python, and machine learning to recommend music. It aims to analyze ListenBrainz data to find connections between songs and deliver personalized recommendations — all without relying on commercial APIs.

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

- Initialize the musicbrainz-server with the latest [MusicBrainz fullexport](https://data.metabrainz.org/pub/musicbrainz/data/fullexport/)

- Download the [Canonical MetaBrainz data](https://data.metabrainz.org/pub/musicbrainz/canonical_data/)

- Run the rake task:

```bash
    bin/rake musicbrainz:initialize[CANONICAL_DATA_PATH]
```


### Initialize the primary database

```bash
    bin/rake wearemusik:initialize
```

### Meilisearch

https://www.meilisearch.com/docs/learn/self_hosted/getting_started_with_self_hosted_meilisearch

- Run the non-commercial version of Meilisearch

- Reindex Meilisearch with the project's models 

```bash
    bin/rails meilisearch:reindex
```