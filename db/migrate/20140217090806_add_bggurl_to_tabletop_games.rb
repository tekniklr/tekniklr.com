class AddBggurlToTabletopGames < ActiveRecord::Migration
  def change
    add_column :tabletop_games, :bgg_url, :string
  end
end
