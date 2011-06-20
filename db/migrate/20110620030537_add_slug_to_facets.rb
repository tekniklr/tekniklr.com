class AddSlugToFacets < ActiveRecord::Migration
  def up
    add_column  :facets,  :slug,  :string
    add_index   :facets,  :slug
  end
  
  def down
    remove_index   :facets,  :slug
    remove_column  :facets,  :slug
  end
end
