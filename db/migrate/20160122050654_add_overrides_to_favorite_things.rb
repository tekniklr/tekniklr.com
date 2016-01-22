class AddOverridesToFavoriteThings < ActiveRecord::Migration
  def change
    add_column :favorite_things, :amazon_url, :string
    add_column :favorite_things, :image_file_name, :string
    add_column :favorite_things, :image_content_type, :string
    add_column :favorite_things, :image_file_size, :integer
    add_column :favorite_things, :image_updated_at, :datetime
  end
end
