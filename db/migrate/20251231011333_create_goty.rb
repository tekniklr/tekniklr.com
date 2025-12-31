class CreateGoty < ActiveRecord::Migration[8.1]
  def change
    create_table :goty do |t|
      t.integer :year
      t.timestamps
    end
    create_table :goty_games do |t|
      t.integer :goty_id
      t.integer :game_id
      t.integer :sort
      t.text    :explanation
      t.timestamps
    end
  end
end
