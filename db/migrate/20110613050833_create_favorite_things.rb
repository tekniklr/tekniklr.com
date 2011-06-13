class CreateFavoriteThings < ActiveRecord::Migration
  def change
    create_table :favorite_things do |t|
      t.integer :type_id
      t.string :thing
      t.string :link
      t.integer :order

      t.timestamps
    end
  end
end
