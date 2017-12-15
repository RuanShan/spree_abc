#require 'spree/core/controller_helpers/common'
# spree/api/base>action_base, spree/base>application
# both included controller_helper/store
#class << Spree::Core::ControllerHelpers::Common
#  def included_with_theme_support(receiver)
#    included_without_theme_support(receiver)
#    receiver.send :include, SpreeTheme::DatabaseTheme::Installer
#    receiver.send :include, SpreeTheme::FileTheme::Installer
#    # template holds data for page render, we have to initialize it even for api
#    receiver.send :prepend_before_action, :initialize_template
#    # receiver could be Spree::Api::BaseController or  Spree::BaseController
#    #if receiver == Spree::BaseController
#    receiver.send :layout, :get_layout_if_use # never allow it to api controller.
#  end
#  alias_method_chain :included, :theme_support
#end


#module SpreeTheme::System
#  def self.included( receiver )
#    super
#    receiver.send :include, SpreeTheme::DatabaseTheme::Installer
#    receiver.send :include, SpreeTheme::FileTheme::Installer
#    # template holds data for page render, we have to initialize it even for api
#    receiver.send :prepend_before_action, :initialize_template
#    # receiver could be Spree::Api::BaseController or  Spree::BaseController
#    #if receiver == Spree::BaseController
#    receiver.send :layout, :get_layout_if_use # never allow it to api controller.
#  end
#end
