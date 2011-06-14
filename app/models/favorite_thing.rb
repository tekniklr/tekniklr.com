class FavoriteThing < ActiveRecord::Base
  attr_accessible :thing, :link, :order
  
  belongs_to  :favorite
  
  validates_presence_of     :favorite_id
  validates_numericality_of :favorite_id
  
  validates_presence_of :thing
  validates_length_of   :thing, :maximum => 60
  
  validates_length_of   :link, :maximum => 60,     :allow_nil => true
  validates_format_of   :link, :with => URI.regexp, :allow_nil => true
  
  validates_presence_of     :order
  validates_numericality_of :order
  
  default_scope :order => "'order' asc, thing asc"
  
end
