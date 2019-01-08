class TabletopGame < ApplicationRecord

  has_attached_file     :image,
                        :styles => { :default => ["100x100>", :png] },
                        :path => ":rails_root/public/tabletop_games/:attachment/:id/:style/:filename",
                        :url => "/tabletop_games/:attachment/:id/:style/:filename"
  validates_attachment_content_type :image, :content_type => [ 'image/png', 'image/jpg', 'image/jpeg', 'image/gif']

  validates_presence_of :name
  default_scope { order('name asc') }
end
