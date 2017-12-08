# This migration comes from spree (originally 20131127001002)
class AddPositionToPostsTaxons < ActiveRecord::Migration
  def change
    add_column :spree_posts_taxons, :id, :primary_key
    add_column :spree_posts_taxons, :position, :integer
    Spree::PostClassification.all.reverse.each{|classfication|
      classfication.insert_at( )
    }
  end
end
