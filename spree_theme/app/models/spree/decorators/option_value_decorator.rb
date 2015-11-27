Spree::OptionValue.class_eval do
  has_one :image, as: :viewable, dependent: :destroy, class_name: "Spree::Image"
  accepts_nested_attributes_for :image
  # for unknown reason accepts_nested_attributes_for do not enable image_attributes
  #attr_accessible :image_attributes
  scope :for_product, ->(product) { select("DISTINCT #{table_name}.*").where("spree_option_values_variants.variant_id IN (?)", product.variant_ids).joins(:variants)  }

  before_save :set_viewable

  private
  def set_viewable
    if image.present?
      image.viewable_type = 'Spree::OptionValue'
      image.viewable_id = self.id
    end
  end
end
