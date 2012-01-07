class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }
  caches_action   :acknowledgments, :layout => false
  caches_action   :navigation,      :layout => false
  caches_action   :routing_error,   :layout => false

  def index
    @tweets      = Tweet.limit(3)
    @post        = Rails.cache.fetch('blog_post', :expires_in => 10.minutes) { get_blog_post }
    @consumption = Rails.cache.fetch('consuming', :expires_in => 2.hours) { get_all_consuming}
    @bookmarks   = Rails.cache.fetch('delicious', :expires_in => 4.hours) { get_delicious }
  end

  def acknowledgments
    page_title 'acknowledgments'
  end

  def navigation
    page_title 'navigation'
  end

  private
  
  def get_blog_post
    logger.debug "Fetching blog post from RSS..."
    require 'rss'
    begin
      rss = RSS::Parser.parse(open('http://tekniklr.com/wpblog/feed/').read, false)
      # iterate through for the first item that is not a twitter recap
      rss.items.each do |item|
        if match = item.title.match(/^Transmissions from/)
          logger.debug "Skipping twitter post"
        else
          logger.debug "Found non-twitter post: #{item.title}"
          return item
        end
      end
    rescue
      ''
    end
  end

  def get_all_consuming
    logger.debug "Fetching all consuming from RSS..."
    require 'rss'
    begin
      rss = RSS::Parser.parse(open('http://www.allconsuming.net/person/tekniklr/rss').read, false)
      rss.items[0..6]
    rescue
      ''
    end
  end
  
  def get_delicious
    logger.debug "Fetching delicious bookmarks from RSS..."
    require 'rss'
    begin
      rss = RSS::Parser.parse(open('http://feeds.delicious.com/v2/rss/tekniklr?count=6').read, false)
      rss.items[0..2]
    rescue
      ''
    end
  end

end
