class Goty < ActiveRecord::Base
  include GotyFormat

  has_many :goty_games, dependent: :destroy

  validates :year, numericality: { greater_than_or_equal_to: 2024, less_than_or_equal_to: Date.today.year }, uniqueness: true

  scope :sorted, -> {
    order('year desc')
  }
  scope :published, -> {
    where(published: true)
  }
  scope :nonempty, -> {
    where.associated(:goty_games).distinct
  }

  def top_num
    case goty_games.size
    when 10..Float::INFINITY
      10
    when 5..9
      5
    when 3,4
      3
    else
      goty_games.size
    end
  end

end