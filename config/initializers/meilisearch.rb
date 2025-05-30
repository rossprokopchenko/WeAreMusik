Meilisearch::Rails.configuration = {
  meilisearch_url: 'http://192.168.2.247:7700',
  meilisearch_api_key: Rails.application.credentials.meilisearch[:key],

  per_page: 50
}
