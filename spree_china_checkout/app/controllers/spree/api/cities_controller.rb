module Spree
  module Api
    class CitiesController < Spree::Api::BaseController
      #initializers/rabl_extra.rb is not working right.
      #get sight from api/controller_setup

      skip_before_action :check_for_user_or_api_key
      skip_before_action :authenticate_user

      def index
        @cities = scope.ransack(params[:q]).result.
                    includes(:state)

        if params[:page] || params[:per_page]
          @cities = @cities.page(params[:page]).per(params[:per_page])
        end

        respond_with(@cities)
      end

      private
        def scope
          if params[:state_id]
            @state = Spree::State.find(params[:state_id])
            return @state.cities
          else
            return Spree::State.where
          end
        end
    end
  end
end
