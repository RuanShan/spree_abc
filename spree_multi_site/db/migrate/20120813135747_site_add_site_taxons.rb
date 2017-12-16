class SiteAddSiteTaxons < ActiveRecord::Migration
  def up
    table_name = Spree::Taxon.connection.table_exists?(:taxons) ? :taxons : :spree_taxons
    add_column table_name, :site_id, :integer
    table_name = Spree::TaxCategory.connection.table_exists?(:tax_categories) ? :tax_categories : :spree_tax_categories
    add_column table_name, :site_id, :integer
    table_name = Spree::ShippingCategory.connection.table_exists?(:shipping_categories) ? :shipping_categories : :spree_shipping_categories
    add_column table_name, :site_id, :integer

    # ShippingMethod.all_available called :all, we have to add default_scope fix it.
    # Zone has_many :shipping_methods, :dependent => :nullify, if zone is deleted, respect shipping_methods.zone_id is set to null
    # for above two reasons, add site_id to shipping_method
    table_name = Spree::ShippingMethod.connection.table_exists?(:shipping_methods) ? :shipping_methods : :spree_shipping_methods
    add_column table_name, :site_id, :integer
    
    table_name = Spree::Prototype.connection.table_exists?(:prototypes) ? :prototypes : :spree_prototypes
    add_column table_name, :site_id, :integer
    table_name = Spree::Property.connection.table_exists?(:properties) ? :properties : :spree_properties
    add_column table_name, :site_id, :integer
    table_name = Spree::OptionType.connection.table_exists?(:option_types) ? :option_types : :spree_option_types
    add_column table_name, :site_id, :integer
    table_name = Spree::Asset.connection.table_exists?(:assets) ? :assets : :spree_assets
    add_column table_name, :site_id, :integer
    table_name = Spree::Preference.connection.table_exists?(:preferences) ? :preferences : :spree_preferences
    add_column table_name, :site_id, :integer, :default=>0 #site_id & key is index, unique, could not be null, or unique would not work.
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
  end

end
