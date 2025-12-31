Rails.application.routes.draw do
  root to: 'main#index'
  
  # omniauth authentication
  get    '/login',                   to: 'sessions#login', as: :login
  match  '/auth/:provider/callback', to: 'sessions#validate', via: [:get, :post]
  get    '/logout',                  to: 'sessions#logout', as: :logout
  get    '/auth/failure',            to: 'sessions#failure'
  
  # clean cache items
  resources :cache, only: [:index, :update]

  # about page
  get '/about',        to: 'about#index'

  # ack
  get '/colophon',     to: 'main#colophon'

  # résumé
  get '/resume',       to: 'resume#index'
  get '/resume/clean', to: 'resume#clean'
  
  # make sure only the html format works for various things
  constraints format: "html" do
    # these are so that wordpress will use the layout generated
    # by rails
    get '/static/headincmeta', to: 'static#headincmeta_partial'
    get '/static/header',      to: 'static#header_partial'
    get '/static/navigation',  to: 'static#navigation_partial'
    get '/static/footer',      to: 'static#footer_partial'
    get '/static/pageend',     to: 'static#pageend_partial'
  end
  
  resources :links, only: [:index, :create, :destroy] do
    patch 'update_all', on: :collection
  end
  
  resources :experiences, except: [:new]
  
  resources :facets,      except: [:new]
  
  resources :favorites do
    post 'sort_favorites', on: :collection
    post 'sort_things',    on: :collection
  end
  
  resources :tabletop_games, except: [:show] do
    get 'manage',            on: :collection
  end

  resources :recent_games, only: [:new, :create,  :edit, :update, :destroy]

  get  '/goty/edit',                 to: 'goty#edit',               as: 'edit_goty'
  get  '/goty/:year',                to: 'goty#show',               as: 'goty'
  post '/goty/sort',                 to: 'goty#sort',               as: 'sort_goty'
  put  '/goty/update/:goty_game_id', to: 'goty#update_explanation', as: 'update_goty_game'

  get '/wpblog(/:blog_params)',           to: 'application#redirect_wordpress'


  # https://github.com/rails/rails/issues/671
  # http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*path', to: "application#routing_error", via: :get
end
