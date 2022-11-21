class FavoriteThing < ApplicationRecord
  belongs_to  :favorite

  has_attached_file     :image,
                        styles: {
                          thumb: ["100x100>", :png],
                          default: ["300x300>", :png]
                        },
                        path: ":rails_root/public/favorite_things/:attachment/:id/:style/:filename",
                        url: "/favorite_things/:attachment/:id/:style/:filename"
  validates_attachment_content_type :image, :content_type => [ 'image/png', 'image/jpg', 'image/jpeg', 'image/gif']
  
  validates_presence_of :thing
  validates_length_of   :thing, :maximum => 60
  
  validates_length_of   :link, :maximum => 90,      :allow_nil => true, :allow_blank => true
  validates_format_of   :link, :with => URI.regexp, :allow_nil => true, :allow_blank => true
  
  validates_presence_of     :sort
  validates_numericality_of :sort
  
  default_scope { order('sort asc, thing asc') }
  
  scope :by_thing_with_image, lambda { |thing|
    where("thing like ?", "%#{thing}%").
    where('image_file_name is not null')
  }

end
