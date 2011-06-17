class Experience < ActiveRecord::Base
  attr_accessible :start_date, :end_date, :title, :affiliation, :location, :tasks
  
  validates_presence_of :title
  validates_length_of   :title, :maximum => 60
  
  validates_presence_of :affiliation
  validates_length_of   :affiliation, :maximum => 60
  
  validates_length_of   :location, :maximum => 60, :allow_nil => true, :allow_blank => true
  
  validates_presence_of :start_date
  validates_date        :start_date
  
  validates_date        :end_date, :allow_nil => true, :allow_blank => true
  
  default_scope :order => 'start_date desc'
end
