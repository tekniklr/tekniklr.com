class RecentGame < ApplicationRecord

  NINTENDO_PLATFORMS =  [
                          'Switch 2',
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
  validates_attachment_content_type :image, content_type: [ 'image/png', 'image/jpg', 'image/jpeg', 'image/gif']
  
  validates_presence_of :name
  validates_length_of   :name, maximum: 72

  validates_presence_of :platform
  validates_length_of   :platform, maximum: 15

  validates_presence_of :last_played
  
  validates_length_of   :url, maximum: 75, allow_blank: true, allow_nil: true
  validates_format_of   :url, with: URI.regexp, allow_blank: true, allow_nil: true
  
  scope :sorted, -> {
    order('last_played desc, updated_at desc')
  }
  scope :visible, -> {
    where(hidden: false)
  }
  scope :by_name, lambda { |name|
    where(name: name)
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
  scope :goty_eligible, -> {
    year = Date.today.year
    where(release_year: year).
    where('created_at <= ?', Time.new(2025,12,31,23,59))
  }

end