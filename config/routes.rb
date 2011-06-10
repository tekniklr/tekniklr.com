TekniklrCom::Application.routes.draw do
  root :to => 'main#index'
  
  # make sure only the html format works for various things
  constraints :format => "html" do
    match 'about' => 'main#about'
    match 'acknowledgments' => 'main#acknowledgments'

    # these are so that wordpress will use the layout generated
    # by rails
    match 'static/headincmeta' => 'static#headincmeta_partial'
    match 'static/header' => 'static#header_partial'
    match 'static/navigation' => 'static#navigation_partial'
    match 'static/footer' => 'static#footer_partial'
    match 'static/pageend' => 'static#pageend_partial'
  end
  
  # restful routing:
  # resources 'main'
  
  # This is a legacy wild controller route that's not recommended for RESTful applications:
  # match ':controller(/:action(/:id(.:format)))'
end
