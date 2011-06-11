class RemoveExperiencesDescription < ActiveRecord::Migration
  def up
    remove_column :experiences, :description
  end

  def down
    add_column    :experiences, :description, :string
  end
end
