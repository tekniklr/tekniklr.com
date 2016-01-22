class AddAmazonUrlToRecentGames < ActiveRecord::Migration
  def change
    add_column :recent_games, :amazon_url, :string
  end
end
