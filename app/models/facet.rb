class Facet < ApplicationRecord
  validates_presence_of    :name
  validates_length_of      :name, maximum: 60
  
  validates_presence_of    :slug
  validates_length_of      :slug, maximum: 12
  
  validates_uniqueness_of  :slug

  default_scope { order('slug asc') }

  def to_s
    value
  end
  
end
