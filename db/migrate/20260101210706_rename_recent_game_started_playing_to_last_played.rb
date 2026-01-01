class RenameRecentGameStartedPlayingToLastPlayed < ActiveRecord::Migration[8.1]
  def change
    rename_column :recent_games, :started_playing, :last_played
  end
end
