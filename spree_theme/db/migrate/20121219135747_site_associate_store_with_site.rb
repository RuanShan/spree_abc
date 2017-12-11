class SiteAssociateStoreWithSite < ActiveRecord::Migration
  def change
    add_column :spree_stores, :site_id, :integer, :default=>0
    Spree::Site.all.each{|site|
      if site.stores.blank?
        site.stores.create!( url: site.domain, name: site.name, code: site.short_name )
      end
    }
  end


end
