class ExperienceSweeper < ActionController::Caching::Sweeper
  observe Experience
  
  def after_create(experience)
    expire_cache_for(experience)
  end
 
  def after_update(experience)
    expire_cache_for(experience)
  end

  def after_destroy(experience)
     expire_cache_for(experience)
  end
  private
  def expire_cache_for(experience)
    expire_action  :controller => 'resume', :action => 'index'
    expire_action  :controller => 'resume', :action => 'clean'
  end
end