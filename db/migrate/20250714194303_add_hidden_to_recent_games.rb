class AddHiddenToRecentGames < ActiveRecord::Migration[8.0]
  def change
    add_column :recent_games, :hidden, :boolean, default: false
  end
end
