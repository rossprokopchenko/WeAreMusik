require "sidekiq/web"

Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # root "home#index"

  match '/', to: 'home#index', via: [:get, :post], as: :root

  post 'add_input_track', to: 'home#add_input_track'
  post 'clear_input_tracks', to: 'home#clear_input_tracks', as: :clear_input_tracks

  resources :tracks

  get "/search", to: "search#index", as: :search

  get "/search/track/:gid", to: "search#show_track", as: :search_track
  get "/search/album/:gid", to: "search#show_album", as: :search_album
  get "/search/artist/:gid", to: "search#show_artist", as: :search_artist

  # get "/profile", to: "profile#index"

  resources :user, param: :gid

  # post "profile/update"

  mount Sidekiq::Web => "/sidekiq"
  
end
