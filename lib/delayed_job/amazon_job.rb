module DelayedJob::AmazonJob

  def get_amazon(item_title, item_type, additional_keywords = '')
    
    # see if this item has been looked up before, only search for it
    # if it hasn't
    cached_amazon_items = Rails.cache.read('amazon_items')
    item_key = "#{item_type}|#{item_title}|#{additional_keywords}"
    if cached_amazon_items && cached_amazon_items.has_key?(item_key)
      Rails.logger.debug "Cached amazon #{item_type}(s) called #{item_title} found"
      return cached_amazon_items[item_key]
    else
      Rails.logger.debug "Cached item not found"

      # keep results cached so each item is only looked up once; even
      # if it was not found
      cached_amazon_items ||= {}

      image_override_name = "products/#{item_title.downcase.gsub(/[^a-z0-9]+/, '_')}.jpg"

      # sometimes we want to link to amazon even if we know in advance the 
      # amazon fetching won't work in the traditional way
      override_links = {
          'Pandemic' => 'http://www.amazon.com/gp/product/B00A2HD40E/ref=as_li_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=B00A2HD40E&linkCode=as2&tag=tekniklrcom-20&linkId=Z3D6CSCEU52FWYB7',
          'Supernatural' => 'http://www.amazon.com/gp/product/B0040FTKNY/ref=as_li_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=B0040FTKNY&linkCode=as2&tag=tekniklrcom-20&linkId=QP4U4EOWRGUSHFSR',
          'Trigun' => 'http://www.amazon.com/gp/product/B00AUJH32E/ref=as_li_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=B00AUJH32E&linkCode=as2&tag=tekniklrcom-20&linkId=BCHVKZZHXGNHT4BQ',
          'Yggdrasil' => 'http://www.amazon.com/gp/product/B004QF0UN2/ref=as_li_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=B004QF0UN2&linkCode=as2&tag=tekniklrcom-20&linkId=BWKCCJPC7GDA5WS5'
        }

      recent_games = RecentGame.by_name_with_image(item_title)
      if !Rails.application.assets.find_asset(image_override_name).nil?
        Rails.logger.debug "Override image found"
        cached_amazon_items[item_key] = {
          :image_url  => ActionController::Base.helpers.image_path(image_override_name),
          :amazon_url => override_links.keys.include?(item_title) ? override_links[item_title] : nil,
          :similarity => 100
        }
      elsif !recent_games.empty?
        Rails.logger.debug "Recent Game with uploaded image found"
        cached_amazon_items[item_key] = {
          :image_url  => recent_games.first.image.url,
          :amazon_url => override_links.keys.include?(item_title) ? override_links[item_title] : nil,
          :similarity => 100
        }
      else
        Rails.logger.debug "Searching amazon for #{item_type}(s) called #{item_title}"
        
        resp = amazon_search(item_title, item_type, additional_keywords)
        if !resp && !additional_keywords.blank? 
          # if we searched with addiional keywords and got no results, try
          # one more time without those keywords
          resp = amazon_search(item_title, item_type)
        end
        resp or return false

        begin
          item = resp.item_search_response.items.item.first
          returned_type = item.item_attributes.product_type_name.__val__
          image_url = item.small_image.blank? ? item.image_sets.first.image_set.small_image.url.__val__ : item.small_image.url.__val__
          amazon_url = item.item_links.first.item_link.first.url.__val__
          # different item types return different parameters. see:
          #   https://docs.aws.amazon.com/AWSECommerceService/latest/DG/LocaleUS.html
          amazon_title  = case returned_type
                          when "DOWNLOADABLE_TV_EPISODE"
                            # unfortunately, amazon results will return the title of the first episode of the series, but not the name of the series. trust amazon returned the correct series. ಠ_ಠ
                            item_title
                          when "ABIS_MUSIC"
                            "#{item.item_attributes.artist ? item.item_attributes.artist.__val__ : item_title} - #{item.item_attributes.title.__val__}"
                          else
                            item.item_attributes.title.__val__
                          end
        rescue
          return false
        end
        
        if image_url && amazon_url
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
      end

      Rails.cache.write('amazon_items', cached_amazon_items)
      return cached_amazon_items[item_key]
    end
  end
  
  private

  # actually perform amazon search
  def amazon_search(item_title, item_type, additional_keywords = '')
    require 'amazon/aws/search'
    result = false
    begin
      result = Amazon::AWS.item_search( item_type, { 
        'Keywords' => "#{item_title}#{additional_keywords.blank? ? '' : ', '+additional_keywords}",
        'IncludeReviewsSummary' => false
      } )
    rescue Amazon::AWS::Error::NoExactMatches
      result = false
    end
    return result
  end

  # sometimes searching for an item would return the correct thing but it
  # would get a low similarity score for stupid subtitle reasons.
  # example:
  #   'lords of waterdeep' != 'lords of waterdeep: a dungeons and dragons game'
  # (and I'm not entering that whole stupid fucking title)
  # going to assume that whatever I enter is the terser version, so only 
  # cleaning up what we get from amazon, here...
  def similarity(thing1, thing2)
    Rails.logger.debug "Checking similarity between \"#{thing1}\" and \"#{thing2}\"..."
    whitelisty_things = [
                          'catan',
                          'skyrim'
                        ]
    if whitelisty_things.select{|t| thing2.downcase =~ /#{t}/}.count > 0
      return 100
    else
      beginnings_thing2 = thing2.downcase.sub(/[-:(0-9].*/, '')
      beginnings = !beginnings_thing2.empty? ? thing1.similar(beginnings_thing2) : 0
      endings_thing2 = thing2.downcase.sub(/.*[-:)]/, '')
      endings = !endings_thing2.empty? ? thing1.similar(endings_thing2) : 0
      middles_thing2 = thing2 =~ /[-:(0-9](.*)[-:)]/ ? $1 : ''
      middles = !middles_thing2.empty? ? thing1.similar(middles_thing2) : 0
      return [beginnings, endings, middles].max
    end
  end

end