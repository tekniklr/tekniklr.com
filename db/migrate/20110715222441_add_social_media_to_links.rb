class AddSocialMediaToLinks < ActiveRecord::Migration
  def change
    add_column  :links,  :social_icon,       :boolean
    add_column  :links,  :icon_file_name,    :string
    add_column  :links,  :icon_content_type, :string
    add_column  :links,  :icon_file_size,    :integer
    add_column  :links,  :icon_updated_at,   :datetime
    add_index   :links,  :social_icon
    add_index   :links,  :visible
  end
end
