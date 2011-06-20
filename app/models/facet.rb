class Facet < ActiveRecord::Base
  attr_accessible :name, :slug, :value
  
  validates_presence_of  :name
  validates_length_of    :name, :maximum => 60
  
  validates_presence_of  :slug
  validates_length_of    :slug, :maximum => 12
  
  default_scope :order => "name asc"
end
