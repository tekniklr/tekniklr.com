class Goty < ActiveRecord::Base

  has_many :goty_games, dependent: :destroy

  validates :year, numericality: { greater_than_or_equal_to: 2025, less_than: 2100 }, uniqueness: true

  scope :sorted, -> {
    order('year desc')
  }

end