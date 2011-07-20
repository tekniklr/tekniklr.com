TekniklrCom::Application.routes.draw do

  root :to => 'main#index'
  
  # omniauth authentication
  match '/login'                   => 'sessions#login', :as => :login
  match "/auth/:provider/callback" => 'sessions#validate'
  match '/logout'                  => 'sessions#logout', :as => :logout
  match '/auth/failure'            => 'sessions#failure'
  
  # about page
  match '/about'  => 'about#index'
  
  # ack
  match '/acknowledgments'    => 'main#acknowledgments'

  # navigation for mobile site
  match '/navigation'    => 'main#navigation'

  # résumé
  match '/resume'       => 'resume#index'
  match '/resume/clean' => 'resume#clean'
  
  # make sure only the html format works for various things
  constraints :format => "html" do
    # these are so that wordpress will use the layout generated
    # by rails
    match '/static/headincmeta' => 'static#headincmeta_partial'
    match '/static/header'      => 'static#header_partial'
    match '/static/navigation'  => 'static#navigation_partial'
    match '/static/footer'      => 'static#footer_partial'
    match '/static/pageend'     => 'static#pageend_partial'
  end
  
  resources :links, :only => [:index, :create, :destroy] do
    put 'update_all', :on => :collection
  end
  
  resources :experiences, :except => [:new]
  
  resources :facets, :except => [:new]
  
  resources :twitter, :only => [:index, :destroy]
  
  resources :favorites do
    put 'sort_favorites', :on => :collection
    put 'sort_things',    :on => :collection
  end
  
  # external redirects
  match "/blog" => redirect("http://tekniklr.com/wpblog"), :as => :blog
  match "/hair" => redirect("http://tekniklr.com/wpblog/2009/10/13/technicolor-hair-howto/"), :as => :hair
  
  # https://github.com/rails/rails/issues/671
  # http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', :to => "application#routing_error"
end
