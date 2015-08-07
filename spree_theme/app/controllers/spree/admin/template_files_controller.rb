module Spree
  module Admin
    class TemplateFilesController < Spree::Admin::ResourceController

      def show
        session[:return_to] ||= request.referer
        redirect_to action: :edit
      end

      def index
        session[:return_to] = request.url
        respond_with(@collection)
      end

      def collection
        model_class.where( ["theme_id in (?)", Spree::Site.current.template_theme_ids] ).order("theme_id").page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end
    end
  end
end
