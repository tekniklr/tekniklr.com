class AddAchievementsToRecentGames < ActiveRecord::Migration[8.0]
  def change
    add_column :recent_games, :achievement_name, :string
    add_column :recent_games, :achievement_time, :datetime
    add_column :recent_games, :achievement_desc, :text
  end
end
