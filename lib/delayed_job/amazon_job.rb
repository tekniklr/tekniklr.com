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
        resp = Amazon::AWS.item_search( item_type, { 
          'Keywords' => item_title,
          'IncludeReviewsSummary' => false
        } )
        item = resp.item_search_response.items.item.first
        returned_type = item.item_attributes.product_type_name.__val__
        image_url = item.small_image.url.__val__
        amazon_url = item.item_links.first.item_link.first.url.__val__
        # different item types return different parameters. see:
        #   https://docs.aws.amazon.com/AWSECommerceService/latest/DG/LocaleUS.html
        amazon_title  = case returned_type
                        when "DOWNLOADABLE_TV_EPISODE"
                          # unfortunately, amazon results will return the title of the first episode of the series, but not the name of the series. trust amazon returned the correct series. ಠ_ಠ
                          item_title
                        when "ABIS_MUSIC"
                          "#{item.item_attributes.artist.__val__} - #{item.item_attributes.title.__val__}"
                        else
                          item.item_attributes.title.__val__
                        end
      rescue
        # could set amazon_values to false here so it gets cached, but
        # i'm assuming this will mostly occur for temporary network problems
        # so it makes sense to try again later
        return false
      end
      
      # keep results cached so each item is only looked up once; even
      # if it was not found
      cached_amazon_items ||= {}
      if !Rails.application.assets.find_asset("products/#{item_title.downcase.gsub(/[^a-z0-9]+/, '_')}.jpg").nil?
        Rails.logger.debug "Preselected image found"
        cached_amazon_items[item_key] = {
          :image_url  => ActionController::Base.helpers.image_path("products/#{item_title.downcase.gsub(/[^a-z0-9]/i, '_')}.jpg")
        }
      elsif image_url && amazon_url
        Rails.logger.debug "Amazon product found"
        cached_amazon_items[item_key] = {
          :image_url    => image_url,
          :amazon_url   => amazon_url,
          :amazon_title => amazon_title,
          :similarity   => similarity(item_title, amazon_title)
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
  def similarity(thing1, thing2)
    Rails.logger.debug "Checking similarity between \"#{thing1}\" and \"#{thing2}\"..."
    beginnings_thing1 = thing1.downcase.sub(/[-:(0-9].*/, '')
    beginnings_thing2 = thing2.downcase.sub(/[-:(0-9].*/, '')
    beginnings = !(beginnings_thing1.empty? && beginnings_thing2.empty?) ? beginnings_thing1.similar(beginnings_thing2) : 0
    endings_thing1 = thing1.downcase.sub(/.*[-:)]/, '')
    endings_thing2 = thing2.downcase.sub(/.*[-:)]/, '')
    endings = !(endings_thing1.empty? && endings_thing2.empty?) ? endings_thing1.similar(endings_thing2) : 0
    [beginnings, endings].max
  end

end