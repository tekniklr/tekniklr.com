class FacetSweeper < ActionController::Caching::Sweeper
observe Link 
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
    expire_fragment :controller => 'about', :action => 'index'
    expire_fragment :controller => 'resume', :action => 'index'
  end
end