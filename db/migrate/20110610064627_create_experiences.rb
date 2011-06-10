class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.date :start_date
      t.date :end_date
      t.string :title
      t.string :affiliation
      t.string :location
      t.string :location
      t.string :description
      t.hash :tasks

      t.timestamps
    end
  end
end
