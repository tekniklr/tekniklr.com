class RenameOrder < ActiveRecord::Migration
  def up
    rename_column :favorites, :order, :sort
    rename_column :favorite_things, :order, :sort
  end

  def down
    rename_column :favorites, :sort, :order
    rename_column :favorite_things, :sort, :order
  end
end
