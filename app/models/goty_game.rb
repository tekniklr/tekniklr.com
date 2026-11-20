class GotyGame < ActiveRecord::Base
  include GotyFormat

  after_save :clear_goty_game_ranks

  belongs_to :goty
  belongs_to :game, class_name: 'RecentGame', foreign_key: :game_id

  validates_presence_of     :sort
  validates_numericality_of :sort

  scope :sorted, -> {
    order('sort asc, created_at asc')
  }

  def rank
    Rails.cache.fetch("goty_game_#{id}_rank") do
      goty_rank = 0
      goty.goty_games.sorted.each_with_index do |gg, index|
        gg.id == id or next
        goty_rank = index+1
        break
      end
      goty_rank
    end
  end

  private

  def clear_goty_game_ranks
    goty.goty_games.each do |gg|
      Rails.cache.delete("goty_game_#{gg.id}_rank")
    end
  end

end