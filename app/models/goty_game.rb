class GotyGame < ActiveRecord::Base

  belongs_to :goty
  belongs_to :game, class_name: 'RecentGame', foreign_key: :game_id

  validates_presence_of     :sort
  validates_numericality_of :sort

  scope :sorted, -> {
    order('sort asc, created_at asc')
  }

end