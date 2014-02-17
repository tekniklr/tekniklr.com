class TabletopGame < ActiveRecord::Base
  attr_accessible :expansions, :name, :other_info, :players

  validates_presence_of :name

  default_scope :order => "name asc"

end