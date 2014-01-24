class TabletopGameSweeper < ActionController::Caching::Sweeper
  observe TabletopGame

  def after_create(tabletop_game)
    expire_cache_for(tabletop_game)
  end
 
  def after_update(tabletop_game)
    expire_cache_for(tabletop_game)
  end

  def after_destroy(tabletop_game)
     expire_cache_for(tabletop_game)
  end
  
  private
  
  def expire_cache_for(tabletop_game)
    expire_action :controller => 'tabletop_games', :action => 'index'
    Rails.cache.delete('tabletop_fetched')
  end
  
end