class AboutController < ApplicationController
  before_filter   { |c| c.page_title 'about Teri', false }
  caches_action   :index, :layout => false
  
  def index
    collect_facets
    build_favorites
  end
  
  private
  
  def collect_facets
    @gravatar_id ||= Digest::MD5::hexdigest(EMAIL).downcase
    @twitter     ||= Facet.find_by_slug('twitter')
    @who         ||= Facet.find_by_slug('who')
    @messaging   ||= Facet.find_by_slug('messaging')
    @definition  ||= Facet.find_by_slug('definition')
    @location    ||= Facet.find_by_slug('location')
    @tech        ||= Facet.find_by_slug('tech')
    @interests   ||= Facet.find_by_slug('interests')
    @about_links ||= Link.get_visible
  end
  
  def build_favorites
    @favorites = Favorite.all
    @things    = Rails.cache.fetch('things_amazon', :expires_in => 12.hours) { get_things_amazon }
  end
  
  def get_things_amazon
    things = []
    @favorites.each do |favorite|
      case favorite.favorite_type
      when "Movies" || "TV" || "Anime"
        amazon_type = 'DVD'
      when "Literature"
        amazon_type = 'Books'
      when "Video Games"
        amazon_type = 'VideoGames'
      when "Music"
        amazon_type = 'Music'
      end
      if amazon_type
        favorite.favorite_things.each do |thing|
          amazon_data = get_amazon(thing.thing, amazon_type)
          if amazon_data
            logger.debug "Amazon product found!"
            things[thing.id] = {
              :image_url  => amazon_data[:image_url],
              :amazon_url => amazon_data[:amazon_url]
            }
          end
        end
      end
    end
    things
  end
  
end
