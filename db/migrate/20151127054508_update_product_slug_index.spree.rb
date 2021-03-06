# This migration comes from spree (originally 20141217215630)
class UpdateProductSlugIndex < ActiveRecord::Migration
  def change
    remove_index :spree_products, :slug
    add_index :spree_products, [:site_id, :slug], :name => "index_spree_products_on_slug", :unique => true

  end
end
