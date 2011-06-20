class Tweet < ActiveRecord::Base
  establish_connection :wordpress
  set_table_name       "wp_ak_twitter"
  set_primary_key      'ID'
  
  default_scope :order => 'tw_created_at desc', :limit => 25
  
  # will linkify @s and #s and links
  def tweet
    tweet = self.tw_text
    
    # links
    tweet.gsub!(/((http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?)/, '<a href="\1">\1</a>')
    
    # mentions
    tweet.gsub!(/@([_\w]+)/, '<a href="http://twitter.com/\1">@\1</a>')
    
    # hashtags
    tweet.gsub!(/#([\w]+)/, '<a href="http://twitter.com/search?q=%23\1">@\1</a>')
    
    # in reply to?
    if !self.tw_reply_username.blank? && !self.tw_reply_tweet.blank?
      tweet << "\n<p class='tweet-reply'><a href='http://twitter.com/#{self.tw_reply_username}/statuses/#{self.tw_reply_tweet}'>in reply to @#{self.tw_reply_username}</a></p>"
    end
    
    tweet
  end
  
end
