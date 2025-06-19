# WeAreMusic introduction

A web application developed in Ruby on Rails which uses the MusicBrainz music encyclopedia, machine learning and its users to recommend music. The project uses Python and machine learning to find correlations between track data and recommends users tracks.

## How to start using WeAreMusik

At the point of writing this, the application is not hosted and is not publicly available.

## Development

### Pre-requisites

* Ruby 3.4.3

* Rails 8.0.2

* Python 3.12.3

* PostgreSQL 16

* Docker (latest)

### MusicBrainz Server

https://github.com/metabrainz/musicbrainz-server


### Meilisearch

https://www.meilisearch.com/docs/learn/self_hosted/getting_started_with_self_hosted_meilisearch

<code>
bin/rails meilisearch:reindex
</code>