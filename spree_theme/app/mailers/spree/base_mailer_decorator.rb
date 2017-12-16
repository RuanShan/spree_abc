  Spree::BaseMailer.class_eval do
    
    #before_action :initialize_mail_settings #it is supported by rails4
    
    # initialize setting for current site, copy from MailMethodsController
    def initialize_mail_settings
      Spree::Core::MailSettings.init
    end
  end
