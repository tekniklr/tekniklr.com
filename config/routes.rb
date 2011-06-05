TekniklrCom::Application.routes.draw do
  root :to => 'main#index'
  
  match 'login' => 'application#login'
  match 'logout' => 'application#logout'
  
  # these are so that wordpress will use the layout generated
  # by rails
  match 'static/headincmeta' => 'static#headincmeta_partial'
  match 'static/header' => 'static#header_partial'
  match 'static/navigation' => 'static#navigation_partial'
  match 'static/footer' => 'static#footer_partial'
  match 'static/pageend' => 'static#pageend_partial'
  
  resources :main

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
