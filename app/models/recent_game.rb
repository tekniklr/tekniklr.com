class RecentGame < ActiveRecord::Base
  has_attached_file     :image,
                        :styles => { :default => ["60x75>", :png] },
                        :path => ":rails_root/public/recent_games/:attachment/:id/:style/:filename",
                        :url => "/recent_games/:attachment/:id/:style/:filename"
  validates_attachment_content_type :image, :content_type => [ 'image/png', 'image/jpg', 'image/gif']
  
  validates_presence_of :name
  validates_length_of   :name, maximum: 72

  validates_presence_of :platform
  validates_length_of   :platform, maximum: 12

  validates_presence_of :started_playing
  validates_date        :started_playing
  
  validates_length_of   :url, maximum: 75, allow_blank: true, allow_nil: true
  validates_format_of   :url, with: URI.regexp, allow_blank: true, allow_nil: true

  default_scope { order('started_playing desc, created_at desc') }
  
end