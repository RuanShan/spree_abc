    Spree::Admin::ProductsController.class_eval do
      update.before :prepare_more_params
      create.before :prepare_more_params
      around_filter :only=>[:create,:edit, :update, :destroy] do |controller, action_block|
        Spree::MultiSiteSystem.with_context_free_taxon{
          action_block.call
        }
      end


      private
      def prepare_more_params
        if params[:product][:global_taxon_ids].present?
          params[:product][:global_taxon_ids] = params[:product][:global_taxon_ids].split(',')
        end
      end

    end
