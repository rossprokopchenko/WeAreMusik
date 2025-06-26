Meilisearch::Rails.configuration = {
  meilisearch_url: Rails.application.credentials.meilisearch[:url],
  meilisearch_api_key: Rails.application.credentials.meilisearch[:key],

  per_page: 50
}
