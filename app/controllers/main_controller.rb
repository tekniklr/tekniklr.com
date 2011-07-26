class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }
  caches_action   :acknowledgments, :layout => false
  caches_action   :navigation,      :layout => false
  caches_action   :routing_error,   :layout => false

  def index
    @tweets      = Tweet.limit(3)
    #@post        = Rails.cache.fetch('blog_post', :expires_in => 10.minutes) { get_blog_post }
    @post        = get_blog_post
    @consumption = Rails.cache.fetch('consuming', :expires_in => 2.hours) { get_all_consuming}
    @music       = Rails.cache.fetch('last_fm',   :expires_in => 15.minutes) { get_last_fm }
    @xbox        = Rails.cache.fetch('xbox',      :expires_in => 2.hours) { get_xbox }
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
      rss.items[1..7]
    rescue
      ''
    end
  end
  
  def get_last_fm
    logger.debug "Fetching last.fm from RSS..."
    require 'rss'
    begin
      rss = RSS::Parser.parse(open('http://ws.audioscrobbler.com/1.0/user/tekniklr/recenttracks.rss').read, false)
      rss.items[1..5]
    rescue
      ''
    end
  end

  def get_xbox
    logger.debug "Fetching xbox achievements from RSS..."
    require 'rss'
    begin
      rss = RSS::Parser.parse(open('http://www.trueachievements.com/myachievementfeedrss.aspx?gamerid=294291').read, false)
      rss.items[1..3]
    rescue
      ''
    end
  end

end
