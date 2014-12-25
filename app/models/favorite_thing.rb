class FavoriteThing < ActiveRecord::Base
  belongs_to  :favorite
  
  validates_presence_of :thing
  validates_length_of   :thing, :maximum => 60
  
  validates_length_of   :link, :maximum => 90,      :allow_nil => true, :allow_blank => true
  validates_format_of   :link, :with => URI.regexp, :allow_nil => true, :allow_blank => true
  
  validates_presence_of     :sort
  validates_numericality_of :sort
  
  default_scope { order('sort asc, thing asc') }
  
end
