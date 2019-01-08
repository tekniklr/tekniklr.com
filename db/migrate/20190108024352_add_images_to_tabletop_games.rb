class AddImagesToTabletopGames < ActiveRecord::Migration[5.2]
  def change
    add_column :tabletop_games, :image_file_name, :string
    add_column :tabletop_games, :image_content_type, :string
    add_column :tabletop_games, :image_file_size, :integer
    add_column :tabletop_games, :image_updated_at, :datetime
  end
end
