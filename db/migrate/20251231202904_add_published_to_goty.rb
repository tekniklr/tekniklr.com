class AddPublishedToGoty < ActiveRecord::Migration[8.1]
  def change
    add_column :goty, :published, :boolean, default: false
  end
end
