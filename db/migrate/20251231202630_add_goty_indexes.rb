class AddGotyIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :goty,       :year,    unique: true
    add_index :goty_games, :goty_id
  end
end
