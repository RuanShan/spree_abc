    Spree::Admin::GeneralSettingsController.class_eval do
      #override original, update site model
      def edit
        @preferences_security = [:allow_ssl_in_production,
                        :allow_ssl_in_staging, :allow_ssl_in_development_and_test,
                        :check_for_spree_alerts]
        @preferences_currency = [:display_currency, :hide_cents]
      end


      def update
        #params.each do |name, value|
        #  next unless Spree::Config.has_preference? name
        #  Spree::Config[name] = value
        #end
        current_store.update_attributes store_params

        current_store.site.update_attributes site_params

        flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:general_settings))
        redirect_to edit_admin_general_settings_path
      end

      def site_params
        params.require(:site).permit(Spree::PermittedAttributes.site_attributes)
      end

    end
