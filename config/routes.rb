TekniklrCom::Application.routes.draw do
  root :to => 'main#index'
  
  # omniauth authentication
  get '/login',                   to: 'sessions#login', :as => :login
  get "/auth/:provider/callback", to: 'sessions#validate'
  get '/logout',                  to: 'sessions#logout', :as => :logout
  get '/auth/failure',            to: 'sessions#failure'
  
  # about page
  get '/about',        to: 'about#index'

  # ack
  get '/colophon',     to: 'main#colophon'

  # résumé
  get '/resume',       to: 'resume#index'
  get '/resume/clean', to: 'resume#clean'
  
  # make sure only the html format works for various things
  constraints :format => "html" do
    # these are so that wordpress will use the layout generated
    # by rails
    get '/static/headincmeta', to: 'static#headincmeta_partial'
    get '/static/header',      to: 'static#header_partial'
    get '/static/navigation',  to: 'static#navigation_partial'
    get '/static/footer',      to: 'static#footer_partial'
    get '/static/pageend',     to: 'static#pageend_partial'
  end
  
  resources :links, :only => [:index, :create, :destroy] do
    patch 'update_all', :on => :collection
  end
  
  resources :experiences, :except => [:new]
  
  resources :facets,      :except => [:new]
  
  resources :favorites do
    patch 'sort_favorites', :on => :collection
    patch 'sort_things',    :on => :collection
  end
  
  resources :tabletop_games, :except => [:show] do
    get 'manage',            :on => :collection
  end

  # https://github.com/rails/rails/issues/671
  # http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', :to => "application#routing_error", :via => :get
end
