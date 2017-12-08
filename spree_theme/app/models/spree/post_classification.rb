#copy from spree/core/model/spree/classification
module Spree
  class PostClassification < ActiveRecord::Base
    self.table_name = 'spree_posts_taxons'
    acts_as_list scope: :taxon
    belongs_to :post, class_name: "Spree::Post", inverse_of: :post_classifications, touch: true
    belongs_to :taxon, class_name: "Spree::Taxon", touch: true

    # For #3494
    validates_uniqueness_of :taxon_id, :scope => :post_id, :message => :already_linked
  end
end
