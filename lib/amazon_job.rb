module AmazonJob
    
  def get_amazon(item_title, item_type)
    Rails.logger.debug "Searching amazon for a/n #{item_type} called #{item_title}"
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
      return {
        :image_url  => item.small_image.url.__val__,
        :amazon_url => item.item_links.first.item_link.first.url.__val__
      }
    rescue
      false
    end
  end
  
end