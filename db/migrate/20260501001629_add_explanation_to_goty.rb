class AddExplanationToGoty < ActiveRecord::Migration[8.1]
  def change
    add_column :goty, :explanation, :text
  end
end
