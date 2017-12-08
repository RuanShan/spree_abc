# This migration comes from spree (originally 20121124203911)
class AddCoverToPost < ActiveRecord::Migration
  def change
  	add_column :spree_posts, :position, :integer, :default => 0
  	add_column :spree_posts, :cover_file_name,     :string
    add_column :spree_posts, :cover_content_type,  :string     
    add_column :spree_posts, :cover_file_size,     :integer, :default => 0
    add_column :spree_posts, :cover_updated_at,    :datetime
  end
end
