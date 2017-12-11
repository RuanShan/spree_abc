module Spree
  module ProductExtraScope
    extend ActiveSupport::Concern
    included do
      # for search
      # copy from  spree_core/product/scopes
      add_search_scope :in_global_taxon do |taxon|
        select("spree_products.id, spree_products.*").
        where(id: Spree::GlobalClassification.select('spree_products_global_taxons.product_id').
              joins(:taxon).
              where(Spree::Taxon.table_name => { :id => taxon.self_and_descendants.pluck(:id) })
             )
      end
      
      add_search_scope :theme_only do
        where("#{Spree::Product.quoted_table_name}.theme_id>0")
      end
      
    end
  end
end