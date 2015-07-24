class CreateRecentGames < ActiveRecord::Migration
  def change
    create_table :recent_games do |t|
      t.string    :name
      t.string    :platform
      t.datetime  :started_playing
      t.string    :url
      t.string    :image_file_name
      t.string    :image_content_type
      t.integer   :image_file_size
      t.datetime  :image_updated_at

      t.timestamps
    end
  end
end
