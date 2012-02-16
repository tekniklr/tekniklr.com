class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }
  caches_action   :acknowledgments, :layout => false
  caches_action   :navigation,      :layout => false
  caches_action   :routing_error,   :layout => false

  def index
    @tweets      = Tweet.limit(50).reject{|t| !t.tw_reply_username.blank?}.first(3)
    @post        = Rails.cache.fetch('blog_post', :expires_in => 15.minutes) { get_blog_post }
    @getglue     = Rails.cache.fetch('getglue',   :expires_in => 2.hours) { get_getglue }
    @bookmarks   = Rails.cache.fetch('delicious', :expires_in => 2.hours) { get_delicious }
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
    begin
      feed = Feedzirra::Feed.fetch_and_parse('http://tekniklr.com/wpblog/feed/')
      feed.entries.reject{|e| e.title =~ /^Transmissions from/}.first
    rescue
      ''
    end
  end

  def get_delicious
    logger.debug "Fetching delicious bookmarks from RSS..."
    begin
      feed = Feedzirra::Feed.fetch_and_parse('http://feeds.delicious.com/v2/rss/tekniklr?count=4')
      feed.entries[0..4]
    rescue
      ''
    end
  end

  def get_getglue
    logger.debug "Fetching getglue checkins from RSS..."
    begin
      parsed_items = []
      feed = Feedzirra::Feed.fetch_and_parse('http://feeds.getglue.com/checkins/0%22jFMxg4Rtl')
      items = feed.entries.uniq_by{|i| i.title}
      items.each do |item|
        logger.debug "Parsing #{item.title}..."
        item.title.gsub!(/Teri Solow is ([A-Za-z]+) (to )?/, '')
        case $1
        when "watching"
          type = 'DVD'
        when "reading"
          type = 'Books'
        when "playing"
          type = 'VideoGames'
        when "listening"
          type = 'Music'
        end
        if type
          amazon = get_amazon(item.title, type)
          if amazon
            logger.debug "Amazon product found!"
            parsed_items << {
              :title      => item.title,
              :url        => item.url,
              :published  => item.published,
              :image_url  => amazon[:image_url],
              :amazon_url => amazon[:amazon_url]
            }
          end
        end
      end
      parsed_items
    rescue
      ''
    end
  end

end
