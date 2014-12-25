class Link < ActiveRecord::Base
  has_attached_file     :icon,
                        :styles => { :default => ["32x32#", :png] },
                        :path => ":rails_root/public/icons/:attachment/:id/:style/:filename",
                        :url => "/icons/:attachment/:id/:style/:filename"
  validates_attachment_content_type :icon, :content_type => [ 'image/png', 'image/jpg', 'image/gif']
  
  validates_presence_of :name
  validates_length_of   :name, :maximum => 36
  
  validates_presence_of :url
  validates_length_of   :url, :maximum => 75
  validates_format_of   :url, :with => URI.regexp

  validates_inclusion_of :visible, :in => [true, false], :allow_nil => true

  default_scope { order('name asc') }

  # will only return links where visible is set to true
  scope :get_visible, -> { where('visible = ?', true)
  }  
  # will only return links where social_icon is set to true and an icon exists
  scope :get_social, -> { where('social_icon = ? and icon_file_name is not null', true) }
  
end
