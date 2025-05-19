class CacheController < ApplicationController
  before_action   :is_admin?
  before_action   { |c| c.page_title 'cache control' }

  def index
  end

  def update
    clean_caches = []
    cache_key = params[:id]
    case cache_key
    when 'gaming_expiry'
      clean_caches = ['fetch_nintendo', 'fetch_psn', 'fetch_steam', 'fetch_xbox', cache_key]
    else
      clean_caches = [cache_key]
    end
    descriptor = (clean_caches.size == 1) ? 'cached item' : 'cached items'

    deleted = []
    clean_caches.each do |cache_item|
      Rails.cache.delete(cache_item) and deleted<<cache_item
    end

    if deleted.size == clean_caches.size
      flash[:notice] = "Baleeted the following #{descriptor}: #{deleted.to_sentence}"
    else
      flash[:error] = "Unable to remove all #{descriptor}: #{clean_caches.to_sentence} (#{deleted.empty? ? 'none' : deleted.to_sentence} removed)"
    end
    redirect_to cache_index_path
  end

end
