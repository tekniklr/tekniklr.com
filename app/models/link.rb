class Link < ActiveRecord::Base
  attr_accessible :name, :url  
  
  validates_presence_of :name
  validates_length_of   :name, :maximum => 36
  
  validates_presence_of :url
  validates_length_of   :url, :maximum => 60
  validates_format_of   :url, :with => URI.regexp

  default_scope :order => 'name asc'

  # will only return links where visible is set to true
  scope :get_visible, where('visible = ?', true)

end
