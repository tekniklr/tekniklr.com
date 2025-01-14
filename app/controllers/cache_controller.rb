class CacheController < ApplicationController
  before_action   :is_admin?
  before_action   { |c| c.page_title 'cache control' }

  def index
  end

  def update
    cache_key = params[:id]
    if Rails.cache.delete(cache_key)
      flash[:notice] = "Baleeted the following cache item: #{cache_key}"
    else
      flash[:error] = "Unable to remove cache item: #{cache_key}!"
    end
    redirect_to cache_index_path
  end

end
