module Spree
  module Admin::SitesHelper
    # spree's error_message_on would cause error in app/views/spree/admin/sites/_user.html.erb 
    # ActionView::Template::Error (`@site[users_attributes][0]' is not allowed as an instance variable name)
    # use this replace it original :error_message_on
    def customer_error_message_on(f,method)
      # it is copied from spree_core/app/helper/spree/admin/base_helper.rb #12 error_message_on
      obj = f.object
      if obj && obj.errors[method].present?
        errors = obj.errors[method].map { |err| h(err) }.join('<br />').html_safe
        content_tag(:span, errors, :class => 'formError')
      else
        ''
      end 
    end
  end
end