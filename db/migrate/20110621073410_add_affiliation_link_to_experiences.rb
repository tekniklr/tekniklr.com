class AddAffiliationLinkToExperiences < ActiveRecord::Migration
  def up
    add_column  :experiences,  :affiliation_link,  :string
    add_index   :experiences,  :affiliation_link
  end
  
  def down
    remove_column  :experiences,  :affiliation_link
    remove_index   :experiences,  :affiliation_link
  end
end
