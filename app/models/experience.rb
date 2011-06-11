class Experience < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :affiliation
  validates_presence_of :start_date
end
