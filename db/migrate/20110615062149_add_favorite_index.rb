class AddFavoriteIndex < ActiveRecord::Migration
  def up
    add_index :favorite_things, :favorite_id
  end

  def down
    remove_index :favorite_things, :favorite_id
  end
end
