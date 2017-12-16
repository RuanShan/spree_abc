class SiteCreateSites < ActiveRecord::Migration
  def self.up
    # disable default site during migration,
    # or default :site cause error before site_id added.
    Spree::MultiSiteSystem.multi_site_context = 'admin_sites'
    create_table :spree_sites do |t|
      t.string :name
      t.string :domain
      t.integer :status, default: 0

      t.string :layout
      t.string :short_name
      t.integer :parent_id
      t.integer :rgt
      t.integer :lft

      #add has_sample
      t.boolean :has_sample,  :default=>false
      t.boolean :loading_sample,  :default=>false

      t.timestamps
    end
  end

  def self.down
    drop_table :spree_sites
  end
end
