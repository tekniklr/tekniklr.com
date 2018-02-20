class Favorite < ApplicationRecord
  has_many  :favorite_things, :dependent => :destroy
  accepts_nested_attributes_for :favorite_things, :reject_if => proc { |attributes| attributes['thing'].blank? }, :allow_destroy => true
  
  validates_presence_of :favorite_type
  validates_length_of   :favorite_type, :maximum => 24
  
  validates_presence_of     :sort
  validates_numericality_of :sort
  
  default_scope { order('sort asc, favorite_type asc') }
  scope :with_things, -> { includes(:favorite_things) }
  scope :with_type, lambda { |type|
    where(favorite_type: type)
  }
  scope :thing_matches, lambda { |thing_name|
    # added this scope to demonstrate a rails 5.1.5 problem I'm experiencing
    # (in more complicated tables) at work. Favorite.with_things works as
    # expected, and Favorite.thing_matches("x") works as expected. however,
    # Favorite.thing_matches("x").with_things returns a completely useless
    # ActiveRecord::Relation object as the generated SQL joins the tables
    # twice. also, thing_matches doesn't work on its own if called with
    # .includes(:favorite_things) and .references(:favorite_things), which was
    # a working construction in rails 5.1.4
    joins(:favorite_things).
    where("UPPER(#{FavoriteThing.table_name}.thing) like ?", "%#{thing_name.upcase}%")
  }
  
end
