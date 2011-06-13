class RenameFavoriteType < ActiveRecord::Migration
  def up
    rename_column :favorites, :type, :favorite_type
    rename_column :favorite_things, :type_id, :favorite_id
  end

  def down
    rename_column :favorites, :favorite_type, :type
    rename_column :favorite_things, :favorite_id, :type_id
  end
end
