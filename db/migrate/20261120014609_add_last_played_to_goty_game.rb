class AddLastPlayedToGotyGame < ActiveRecord::Migration[8.1]
  def change
    add_column :goty_games, :last_played, :date
    GotyGame.all.each do |gg|
      gg.update_attribute(:last_played, gg.game.last_played.to_date)
    end
  end
end
