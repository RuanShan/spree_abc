class RenamePermalinkToSlugForPosts < ActiveRecord::Migration
  def change
    rename_column :spree_posts, :permalink, :slug
  end
end
