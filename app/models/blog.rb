class Blog < ApplicationRecord
  # the posts table in my wordpress

  self.establish_connection :wordpress
  self.table_name = 'wp_posts'

  scope :sorted, -> { order('post_date desc') }
  scope :published, -> { where(post_status: 'publish')}
  scope :posts, -> { where(post_type: 'post') }

  def trash!
    self.post_status = 'trash'
    self.save(validate: false)
  end

  # I use the FeedWordPress plugin to import posts from my tumblr, but it's
  # REAL GOOD at pulling in the same post two, three, more times. delete the
  # dupes.
  def self.remove_duplicates
    posts = Blog.posts.published.sorted.limit(20)
    previous_guid = false
    posts.each do |post|
      if post.guid == previous_guid
        logger.debug "************ trashing duplicate post with guid #{post.guid}!"
        post.trash!
      end
      previous_guid = post.guid
    end
  end

  # who knows what lurks in the depths??? er, lurked.
  def self.remove_old!
    Blog.posts.published.where('post_date < ?', Date.today-3.years).each do |post|
      post.trash!
    end
  end

end
