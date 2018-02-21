class Favorite < ApplicationRecord
  has_many  :favorite_things, :dependent => :destroy
  accepts_nested_attributes_for :favorite_things, :reject_if => proc { |attributes| attributes['thing'].blank? }, :allow_destroy => true
  
  validates_presence_of :favorite_type
  validates_length_of   :favorite_type, :maximum => 24
  
  validates_presence_of     :sort
  validates_numericality_of :sort
  
  default_scope { order("#{Favorite.table_name}.sort asc, #{Favorite.table_name}.favorite_type asc") }
  scope :with_things, -> { includes(:favorite_things) }
  scope :with_type, lambda { |type|
    where(favorite_type: type)
  }
  
end
