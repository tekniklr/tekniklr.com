module DelayedJob::AmazonJob
    
  def get_amazon(item_title, item_type)
    cached_amazon_items = Rails.cache.read('amazon_items')
    item_key = "#{item_type}|#{item_title}"
    if cached_amazon_items && cached_amazon_items[item_key]
      Rails.logger.debug "Cached amazon #{item_type}(s) called #{item_title} found"
      return cached_amazon_items[item_key]
    else
      Rails.logger.debug "Cached item not found; searching amazon for #{item_type}(s) called #{item_title}"
      require 'amazon/aws/search'
      begin
        resp = Amazon::AWS.item_search(
          item_type,
          {
            'Keywords'     => item_title,
            'MinimumPrice' => '0001',
            'MaximumPrice' => '29999'
          }
        )
        item = resp.item_search_response.items.item.first
        amazon_values = {
          :image_url  => item.small_image.url.__val__,
          :amazon_url => item.item_links.first.item_link.first.url.__val__
        }
        cached_amazon_items ||= {}
        cached_amazon_items[item_key] = amazon_values
        Rails.cache.write('amazon_items', cached_amazon_items)
        return amazon_values
      rescue
        false
      end
    end
  end
  
end