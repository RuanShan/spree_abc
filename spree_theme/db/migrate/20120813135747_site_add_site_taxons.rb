class SiteAddSiteTaxons < ActiveRecord::Migration
  def up

    add_column :spree_taxons, :site_id, :integer

    add_column :spree_tax_categories, :site_id, :integer

    add_column :spree_shipping_categories, :site_id, :integer

    # ShippingMethod.all_available called :all, we have to add default_scope fix it.
    # Zone has_many :shipping_methods, :dependent => :nullify, if zone is deleted, respect shipping_methods.zone_id is set to null
    # for above two reasons, add site_id to shipping_method

    add_column :spree_shipping_methods, :site_id, :integer


    add_column :spree_prototypes, :site_id, :integer

    add_column :spree_properties, :site_id, :integer

    add_column :spree_option_types, :site_id, :integer

    add_column :spree_assets, :site_id, :integer

    add_column :spree_preferences, :site_id, :integer, :default=>0 #site_id & key is index, unique, could not be null, or unique would not work.

    add_column :spree_trackers, :site_id, :integer

  end

  def down
    remove_column Spree::Taxon.table_name, :site_id, :integer
    remove_column Spree::TaxCategory.table_name, :site_id
    remove_column Spree::ShippingCategory.table_name, :site_id
    remove_column Spree::ShippingMethod.table_name, :site_id
    remove_column Spree::Prototype.table_name, :site_id
    remove_column Spree::Property.table_name, :site_id
    remove_column Spree::OptionType.table_name, :site_id
    remove_column Spree::Asset.table_name, :site_id
    remove_column Spree::Preference.table_name, :site_id
    remove_column :spree_trackers, :site_id

  end

end
