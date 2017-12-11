class SiteCreateSites < ActiveRecord::Migration
  def self.up
    # disable default site during migration,
    # or default :site cause error before site_id added.
    Spree::MultiSiteSystem.multi_site_context = 'admin_sites'
    create_table :spree_sites do |t|
      t.string :name
      t.string :domain

      t.timestamps
    end
  end

  def self.down
    drop_table :spree_sites
  end
end
