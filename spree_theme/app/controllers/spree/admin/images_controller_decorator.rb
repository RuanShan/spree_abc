Spree::Admin::ImagesController.class_eval do
      #create.before :update_paperclip_settings
      #update.before :update_paperclip_settings
      
      private
      # we do not support this feature now.
      # copy from image_settings_controller
      # by default Spree::Image.attachment_definitions is set before site initialize, we need reset it after get site.
      #def update_paperclip_settings
      #  if Spree::Config[:use_s3]
      #    s3_creds = { :access_key_id => Spree::Config[:s3_access_key], :secret_access_key => Spree::Config[:s3_secret], :bucket => Spree::Config[:s3_bucket] }
      #    Spree::Image.attachment_definitions[:attachment][:storage] = :s3
      #    Spree::Image.attachment_definitions[:attachment][:s3_credentials] = s3_creds
      #    Spree::Image.attachment_definitions[:attachment][:s3_headers] = ActiveSupport::JSON.decode(Spree::Config[:s3_headers])
      #    Spree::Image.attachment_definitions[:attachment][:bucket] = Spree::Config[:s3_bucket]
      #  else
      #    Spree::Image.attachment_definitions[:attachment].delete :storage
      #  end
      #  Spree::Image.attachment_definitions[:attachment][:styles] = ActiveSupport::JSON.decode(Spree::Config[:attachment_styles]).symbolize_keys!
      #  Spree::Image.attachment_definitions[:attachment][:path] = Spree::Config[:attachment_path]
      #  Spree::Image.attachment_definitions[:attachment][:default_url] = Spree::Config[:attachment_default_url]
      #  Spree::Image.attachment_definitions[:attachment][:default_style] = Spree::Config[:attachment_default_style]
      #end
end
