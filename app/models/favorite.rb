class Favorite < ActiveRecord::Base
  attr_accessible :favorite_type, :order
  
  has_many  :favorite_things, :dependent => :destroy
  accepts_nested_attributes_for :favorite_things
  
  validates_presence_of :favorite_type
  validates_length_of   :favorite_type, :maximum => 12
  
  validates_presence_of     :order
  validates_numericality_of :order
  
  default_scope :order => "'order' asc"
  
end
