class LinkSweeper < ActionController::Caching::Sweeper
  observe Link

  def after_create(link)
    expire_cache_for(link)
  end
 
  def after_update(link)
    expire_cache_for(link)
  end

  def after_destroy(link)
     expire_cache_for(link)
  end
  
  private
  
  def expire_cache_for(link)
    expire_action   :controller => 'about',  :action => 'index'
    expire_page     :controller => 'static', :action => 'headincmeta_partial'
    expire_page     :controller => 'static', :action => 'footer_partial'
  end
end