class FacetSweeper < ActionController::Caching::Sweeper
  observe Facet
   
  def after_create(facet)
    expire_cache_for(facet)
  end
 
  def after_update(facet)
    expire_cache_for(facet)
  end

  def after_destroy(facet)
     expire_cache_for(facet)
  end
  private
  def expire_cache_for(facet)
    expire_action   :controller => 'about',  :action => 'index'
    expire_action   :controller => 'resume', :action => 'index'
    expire_action   :controller => 'resume', :action => 'clean'
  end
end