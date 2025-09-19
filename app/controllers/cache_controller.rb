class CacheController < ApplicationController
  before_action   :is_admin?
  before_action   { |c| c.page_title 'cache control' }

  def index
  end

  def update
    clean_caches = []
    cache_key = params[:id]
    clean_caches = [cache_key]
    CACHED_ITEMS.each do |cache_item|
      item_key = cache_item[1]
      (cache_key == item_key) or next
      if cache_item[2]
        clean_caches << cache_item[2]
      end
    end
    clean_caches.flatten!
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
