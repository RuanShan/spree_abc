#encoding: utf-8
module Spree
    BaseController.class_eval do
      prepend_before_action :set_multi_site_scope
      #rescue_from CanCan::AccessDenied do |exception|
      #  return spree_theme_admin_unauthorized
      #end

      #def spree_theme_admin_unauthorized
      #  Rails.logger.debug "yes, it is calling spree_theme_admin_unauthorized"
      #    if try_spree_current_user
      #      flash[:error] = Spree.t(:authorization_failure)
      #      redirect_to '/unauthorized'
      #    else
      #      store_location
      #      url = new_admin_session_path
      #      redirect_to url
      #    end
      #end
      #override spree_core/controller_helper/auth#unauthorized
      #  def unauthorized
      #    url = new_admin_session_path
      #    if try_spree_current_user
      #      flash[:error] = Spree.t(:authorization_failure)
      #      redirect_to admin_login_path
      #    else
      #      store_location
      #      redirect_to admin_login_path
      #    end
      #  end

      def set_multi_site_scope
        Spree::MultiSiteSystem.bind
      end
    end

end

module Spree::Admin
  BaseController.class_eval do
    rescue_from CanCan::AccessDenied do |exception|
      redirect_to  admin_login_path
    end
  end
end
