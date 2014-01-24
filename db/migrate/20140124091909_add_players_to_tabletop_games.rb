class AddPlayersToTabletopGames < ActiveRecord::Migration
  def change
    add_column :tabletop_games, :players, :string
  end
end
