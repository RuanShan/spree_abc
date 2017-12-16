class SiteLastFixUniqueIndex < ActiveRecord::Migration
  def change
    if Spree::Site.table_exists?
      if defined?(Spree::Auth)
        remove_index :spree_users, :slug if index_exists?(:spree_users, :email)
        add_index :spree_users, [:site_id,:email], :unique => true
      end

      remove_index :spree_preferences, :key if index_exists?(:spree_preferences, :key)
      add_index :spree_preferences, [:site_id,:key], :unique => true

      remove_index :spree_products, :slug if index_exists?(:spree_products, :slug)
      add_index :spree_products, [:site_id, :slug], unique: true

    end
  end
end
