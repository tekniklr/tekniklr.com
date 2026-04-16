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

    deleted = []
    clean_caches.each do |cache_item|
      Rails.cache.delete(cache_item) and deleted<<cache_item
    end

    descriptor = (deleted.size == 1) ? 'cached item' : 'cached items'
    flash[:notice] = "Baleeted the following #{descriptor}: #{deleted.to_sentence}"

    redirect_to cache_index_path
  end

end
