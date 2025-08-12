class TabletopGame < ApplicationRecord

  has_attached_file     :image,
                        styles: {
                          thumb: ["100x100>", :png],
                          default: ["300x300>", :png]
                        },
                        path: ":rails_root/public/tabletop_games/:attachment/:id/:style/:filename",
                        url: "/tabletop_games/:attachment/:id/:style/:filename"
  validates_attachment_content_type :image, content_type: [ 'image/png', 'image/jpg', 'image/jpeg', 'image/gif']

  validates_presence_of :name

  scope :sorted, -> {
    order('name asc')
  }

end
