class RemoveAmazonUrls < ActiveRecord::Migration[5.2]
  def change
    remove_column  :favorite_things,  :amazon_url
    remove_column  :recent_games,     :amazon_url
  end
end
