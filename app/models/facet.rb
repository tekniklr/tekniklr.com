class Facet < ApplicationRecord
  validates_presence_of  :name
  validates_length_of    :name, :maximum => 60
  
  validates_presence_of  :slug
  validates_length_of    :slug, :maximum => 12
  
  default_scope { order('slug asc') }

  def to_s
    value
  end
  
end
