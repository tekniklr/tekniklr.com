class FavoriteThing < ActiveRecord::Base
  attr_accessible :favorite_id, :thing, :link, :order
  
  belongs_to  :favorite
  
  validates_presence_of :thing
  validates_length_of   :thing, :maximum => 60
  
  validates_length_of   :link, :maximum => 60,      :allow_nil => true, :if => :link?
  validates_format_of   :link, :with => URI.regexp, :allow_nil => true, :if => :link?
  
  validates_presence_of     :order
  validates_numericality_of :order
  
  default_scope :order => "'order' asc"
  
end
