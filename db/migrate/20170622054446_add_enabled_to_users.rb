class AddEnabledToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :enabled, :boolean, default: false
  end
end
