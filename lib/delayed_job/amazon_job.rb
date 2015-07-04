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
        resp = Amazon::AWS.item_search( item_type, { 'Keywords' => item_title } )
        item = resp.item_search_response.items.item.first
        image_url = item.small_image
        amazon_url = item.item_links.first.item_link.first
        amazon_title = item.item_attributes.title
      rescue
        # could set amazon_values to false here so it gets cached, but
        # i'm assuming this will mostly occur for temporary network problems
        # so it makes sense to try again later
        return false
      end
      
      # keep results cached so each item is only looked up once; even
      # if it was not found
      cached_amazon_items ||= {}
      if !Rails.application.assets.find_asset("products/#{item_title.downcase.gsub(/[^a-z0-9]/i, '_')}.jpg").nil?
        Rails.logger.debug "Preselected image found"
        cached_amazon_items[item_key] = {
          :image_url  => ActionController::Base.helpers.image_path("products/#{item_title.downcase.gsub(/[^a-z0-9]/i, '_')}.jpg")
        }
      elsif image_url && amazon_url
        Rails.logger.debug "Amazon product found"
        cached_amazon_items[item_key] = {
          :image_url    => image_url.url.__val__,
          :amazon_url   => amazon_url.url.__val__,
          :amazon_title => amazon_title.__val__,
          :similarity   => similarity(item_type, item_title, amazon_title.__val__)
        }
      else
        Rails.logger.debug "No image or Amazon product found; no image left to use"
        cached_amazon_items[item_key] = false
      end
      Rails.cache.write('amazon_items', cached_amazon_items)
      
      return cached_amazon_items[item_key]
    end
  end
  
  # sometimes searching for an item would return the correct thing but it
  # would get a low similarity score for stupid subtitle reasons.
  # example:
  #   'lords of waterdeep' != 'lords of waterdeep: a dungeons and dragons game'
  # (and I'm not entering that whole stupid fucking title)
  def similarity(item_type, thing1, thing2)
    (item_type == 'Music') and return 100
    Rails.logger.debug "Checking similarity between \"#{thing1}\" and \"#{thing2}\"..."
    beginnings_thing1 = thing1.sub(/[-:(].*/, '')
    beginnings_thing2 = thing2.sub(/[-:(].*/, '')
    beginnings = !(beginnings_thing1.empty? && beginnings_thing2.empty?) ? beginnings_thing1.similar(beginnings_thing2) : 0
    endings_thing1 = thing1.sub(/.*[-:)]/, '')
    endings_thing2 = thing2.sub(/.*[-:)]/, '')
    endings = !(endings_thing1.empty? && endings_thing2.empty?) ? endings_thing1.similar(endings_thing2) : 0
    [beginnings, endings].max
  end

end