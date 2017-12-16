class SiteAddShortNameAndParentIdToSite < ActiveRecord::Migration
  def self.up
    add_column :spree_sites, :layout, :string
    add_column :spree_sites, :parent_id, :integer
    add_column :spree_sites, :short_name, :string
    add_column :spree_sites, :rgt, :integer
    add_column :spree_sites, :lft, :integer
  end

  def self.down
    remove_column :spree_sites, :layout
    remove_column :spree_sites, :parent_id
    remove_column :spree_sites, :short_name
    remove_column :spree_sites, :lft
    remove_column :spree_sites, :rgt
  end
end
