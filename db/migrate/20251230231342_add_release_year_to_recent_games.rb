class AddReleaseYearToRecentGames < ActiveRecord::Migration[8.1]
  def change
    add_column :recent_games, :release_year, :integer
  end
end
