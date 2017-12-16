class SiteAddHasSample < ActiveRecord::Migration
  def up
    add_column :spree_sites, :has_sample, :boolean, :default=>false
    add_column :spree_sites, :loading_sample, :boolean, :default=>false
  end

  def down
    remove_column :spree_sites, :has_sample
    remove_column :spree_sites, :loading_sample
  end
end
