Spree::Api::V1::VariantsController.class_eval do
  def index
    # since variant have no site_id, we should join product here
    @variants = scope.joins(:product).includes({ option_values: :option_type }, :product, :default_price, :images, { stock_items: :stock_location })
      .ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
    respond_with(@variants)
  end
end
