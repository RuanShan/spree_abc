class SiteAddSiteStatus < ActiveRecord::Migration
  # add feature store disignable
  def change
    add_column :spree_sites, :status, :integer, default: 0
  end
end
