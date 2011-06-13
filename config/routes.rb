TekniklrCom::Application.routes.draw do
  root :to => 'main#index'
  
  # omniauth authentication
  match '/login' => redirect('/auth/twitter/')
  match "/auth/:provider/callback" => 'sessions#validate'
  match '/logout' => 'sessions#logout', :as => :logout
  match '/auth/failure' => 'sessions#failure'
  
  # résumé
  match '/resume' => 'resume#index'
  
  # make sure only the html format works for various things
  constraints :format => "html" do
    match '/about' => 'main#about'
    match '/acknowledgments' => 'main#acknowledgments'

    # these are so that wordpress will use the layout generated
    # by rails
    match '/static/headincmeta' => 'static#headincmeta_partial'
    match '/static/header' => 'static#header_partial'
    match '/static/navigation' => 'static#navigation_partial'
    match '/static/footer' => 'static#footer_partial'
    match '/static/pageend' => 'static#pageend_partial'
  end
  
  resources :links, :only => [:index, :destroy]
  match     'links' => 'links#create_and_update', :via => :post
  
  resources :experiences, :only => [:index, :destroy]
  match     'experiences' => 'experiences#create_and_update', :via => :post
  
  # https://github.com/rails/rails/issues/671
  # http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', :to => "main#routing_error"
end
