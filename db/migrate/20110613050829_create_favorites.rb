class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.string :type
      t.integer :order

      t.timestamps
    end
  end
end
