class Tweet < ActiveRecord::Base
  establish_connection :wordpress
  self.table_name = "wp_ak_twitter"
  self.primary_key = 'ID'
  
  attr_accessible
  
  default_scope :order => 'tw_created_at desc', :limit => 25
  
  # will linkify @s and #s and links
  def tweet
    # convert charset to utf-8
    tweet = Iconv.new('LATIN1', 'utf-8').iconv(tw_text)
    
    # links
    tweet.gsub!(/((http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?)/, '<a href="\1">\1</a>')
    
    # mentions
    tweet.gsub!(/@([_\w]+)/, '<a href="http://twitter.com/\1">@\1</a>')
    
    # hashtags
    tweet.gsub!(/#([\w]+)/, '<a href="http://twitter.com/search?q=%23\1">#\1</a>')
    
    tweet << "\n<footer class='tweet-footer'>"
    
    # in reply to?
    if !self.tw_reply_username.blank? && !self.tw_reply_tweet.blank?
      tweet << "\n<span class='tweet-reply'><a href='http://twitter.com/#{self.tw_reply_username}/statuses/#{self.tw_reply_tweet}'>in reply to @#{self.tw_reply_username}</a></span> "
    end
    
    tweet << "<span class='tweet-when'><a href='http://twitter.com/tekniklr/statuses/#{self.tw_id}'>#{ActionController::Base.helpers.time_ago_in_words(self.tw_created_at)} ago</a></span>"
    
    tweet << "</footer>"
    
    tweet
  end
  
end
