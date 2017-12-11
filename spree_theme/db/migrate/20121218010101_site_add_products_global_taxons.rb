class SiteAddProductsGlobalTaxons < ActiveRecord::Migration
  # we want to display product in www.tld
  # each product should have global taxon( taxon in www.tld )  
  create_table :spree_products_global_taxons, :id => false do |t|
    t.references :product
    t.references :taxon
  end

  add_index :spree_products_global_taxons, [:product_id], :name => 'index_spree_products_global_taxons_on_product_id'
  add_index :spree_products_global_taxons, [:taxon_id],   :name => 'index_spree_products_global_taxons_on_taxon_id'
end
