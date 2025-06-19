module UserHelper
  def search_favorite_releases(user, query, page = 1)
    ids = user.releases.pluck(:id)
  
    return Release.none if ids.empty?
  
    results = Meilisearch::Rails.client
      .index('Release')
      .search(query, {
        filter: "id IN [#{ids.join(',')}]",
        page: page,
        hits_per_page: 50
      })
  
    ids_to_fetch = results['hits'].map { |h| h['id'] }
  
    Release.where(id: ids_to_fetch)
           .includes(:artist_credit)
           .in_order_of(:id, ids_to_fetch)
  end
end