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

  def players_min
    players or return nil
    match = players_regex
    match or return nil
    return match[1]
  end

  def players_max
    players or return nil
    match = players_regex
    match or return nil
    if match[2]
      if match[2] == '+'
        return nil
      elsif (match[2] == '-') && match[3]
        return match[3]
      end
    end
    return match[1]
  end

  #private

  def players_regex
    players.match(/([0-9]+)(\-|\+)?([0-9]+)?/)
  end

end