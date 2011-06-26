class FavoriteSweeper < ActionController::Caching::Sweeper
observe Link 
  def after_create(favorite)
    expire_cache_for(favorite)
  end
 
  def after_update(favorite)
    expire_cache_for(favorite)
  end

  def after_destroy(favorite)
     expire_cache_for(favorite)
  end
  private
  def expire_cache_for(favorite)
    expire_fragment :controller => 'about', :action => 'index'
  end
end