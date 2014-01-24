class CreateTabletopGames < ActiveRecord::Migration
  def change
    create_table :tabletop_games do |t|
      t.string :name
      t.text :expansions
      t.text :other_info

      t.timestamps
    end
  end
end
