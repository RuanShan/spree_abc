class CreateTaxonsPosts < ActiveRecord::Migration
  def self.up
    create_table :spree_posts_taxons, :id => false, :force => true do |t|
      t.integer :post_id
      t.integer :taxon_id
    end
  end

  def self.down
    drop_table :spree_posts_taxons
  end
end
