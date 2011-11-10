class Favorite < ActiveRecord::Base
  attr_accessible :favorite_type, :sort, :favorite_things_attributes
  
  has_many  :favorite_things, :dependent => :destroy
  accepts_nested_attributes_for :favorite_things, :reject_if => proc { |attributes| attributes['thing'].blank? }, :allow_destroy => true
  
  validates_presence_of :favorite_type
  validates_length_of   :favorite_type, :maximum => 24
  
  validates_presence_of     :sort
  validates_numericality_of :sort
  
  default_scope :order => "sort asc, favorite_type asc"
  
end
