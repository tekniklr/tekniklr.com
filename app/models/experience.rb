class Experience < ActiveRecord::Base
  attr_accessible :start_date, :end_date, :title, :affiliation, :location, :tasks
  
  validates_presence_of :title
  validates_presence_of :affiliation
  validates_presence_of :start_date
  
  default_scope :order => 'start_date desc'
end
