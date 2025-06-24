require "sidekiq/web"

Rails.application.routes.draw do
  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  get "/signup", to: "user#new", as: :signup
  post "/signup", to: "user#create"

  get "/verify", to: "user#verify", as: :verify
  post "/verify", to: "user#confirm_verification"
  
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  match '/', to: 'home#index', via: [:get, :post], as: :root

  post 'add_input_track', to: 'home#add_input_track'
  post 'clear_input_tracks', to: 'home#clear_input_tracks', as: :clear_input_tracks

  resources :tracks

  get "/search", to: "search#index", as: :search

  get "/search/track/:gid", to: "search#show_track", as: :search_track
  post "/search/track/:gid/like", to: "search#like_track", as: :like_track

  get "/search/album/:gid", to: "search#show_album", as: :search_album
  post "/search/album/:gid/save", to: "search#save_release", as: :save_release

  get "/search/artist/:gid", to: "search#show_artist", as: :search_artist
  post "/search/artist/:gid/save", to: "search#save_artist", as: :save_artist

  # get "/profile", to: "profile#index"

  resources :user, param: :gid do
    post :follow, on: :member
    delete :unfollow, on: :member
  end

  get "/about", to: "about#index", as: :about
  get "/contact", to: "contact#index", as: :contact

  # post "profile/update"

  mount Sidekiq::Web => "/sidekiq"
  
end
