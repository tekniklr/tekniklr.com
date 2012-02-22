module DelayedJob::AmazonJob
    
  def get_amazon(item_title, item_type)
    
    # see if this item has been looked up before, only search for it
    # if it hasn't
    cached_amazon_items = Rails.cache.read('amazon_items')
    item_key = "#{item_type}|#{item_title}"
    if cached_amazon_items && cached_amazon_items.has_key?(item_key)
      Rails.logger.debug "Cached amazon #{item_type}(s) called #{item_title} found"
      return cached_amazon_items[item_key]
    else
      Rails.logger.debug "Cached item not found; searching amazon for #{item_type}(s) called #{item_title}"
      
      # actually perform amazon search
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
        image_url = item.small_image
        amazon_url = item.item_links.first.item_link.first
      rescue
        # could set amazon_values to false here so it gets cached, but
        # i'm assuming this will mostly occur for temporary network problems
        # so it makes sense to try again later
        return false
      end
      
      # keep results cached so each item is only looked up once; even
      # if it was not found
      cached_amazon_items ||= {}
      if image_url && amazon_url
        Rails.logger.debug "Amazon product found"
        cached_amazon_items[item_key] = {
          :image_url  => image_url.url.__val__,
          :amazon_url => amazon_url.url.__val__
        }
      else
        Rails.logger.debug "Amazon product not found"
        cached_amazon_items[item_key] = false
      end
      Rails.cache.write('amazon_items', cached_amazon_items)
      
      return cached_amazon_items[item_key]
    end
  end
  
end