# This migration comes from spree (originally 20141105213646)
class UpdateClassificationsPositions < ActiveRecord::Migration
  def up
    Spree::Taxon.unscoped.all.each do |taxon|
      taxon.classifications.each_with_index do |c12n, i|
        c12n.set_list_position(i + 1)
      end
    end
  end
end
