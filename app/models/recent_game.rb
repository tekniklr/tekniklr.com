class RecentGame < ApplicationRecord

  NINTENDO_PLATFORMS =  [
                          'Switch',
                          '3DS',
                          'GBA',
                          'SNES',
                          'NES'
                        ]
  PSN_PLATFORMS =       [
                          'PlayStation',
                          'PS5',
                          'PS4'
                        ]
  STEAM_PLATFORMS =     [
                          'Steam'
                        ]
  XBOX_PLATFORMS =      [
                          'Xbox',
                          'Xbox Series X/S',
                          'Xbox One',
                          'Xbox 360'
                        ]
  PLATFORMS = PSN_PLATFORMS + XBOX_PLATFORMS + NINTENDO_PLATFORMS + STEAM_PLATFORMS + ['Mac', 'the internet', 'iOS']

  has_attached_file     :image,
                        styles: {
                          thumb: ["100x100>", :png],
                          default: ["300x300>", :png]
                        },
                        path: ":rails_root/public/recent_games/:attachment/:id/:style/:filename",
                        url: "/recent_games/:attachment/:id/:style/:filename"
  validates_attachment_content_type :image, :content_type => [ 'image/png', 'image/jpg', 'image/jpeg', 'image/gif']
  
  validates_presence_of :name
  validates_length_of   :name, maximum: 72

  validates_presence_of :platform
  validates_length_of   :platform, maximum: 15

  validates_presence_of :started_playing
  
  validates_length_of   :url, maximum: 75, allow_blank: true, allow_nil: true
  validates_format_of   :url, with: URI.regexp, allow_blank: true, allow_nil: true
  
  scope :sorted, -> {
    order('started_playing desc, updated_at desc')
  }
  scope :by_name, lambda { |name|
    name_parts = name.gsub(/[^A-Za-z0-9 ]/, ' ').split(' ')
    clauses = ("name like ? and "*(name_parts.size)).gsub(/ and \z/, '')
    conditions = name_parts.map{|p| "%#{p}%"}
    where([clauses, conditions].flatten)
  }
  scope :on_platform, lambda { |platform|
    platforms = case platform
                when 'psn'
                  PSN_PLATFORMS
                when 'xbox'
                  XBOX_PLATFORMS
                when 'steam'
                  STEAM_PLATFORMS
                when 'switch'
                  NINTENDO_PLATFORMS
                end
    where(platform: platforms)
  }
  scope :with_image, -> {
    where('image_file_name is not null')
  }

end