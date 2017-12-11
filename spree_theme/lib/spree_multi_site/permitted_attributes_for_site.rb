require 'spree/permitted_attributes'
module Spree
  module PermittedAttributes
    ATTRIBUTES_FOR_SITE=[:site_attributes]
    mattr_reader *ATTRIBUTES_FOR_SITE

    @@site_attributes = [:name, :domain, :short_name, :has_sample, :index_page,:theme_id,:foreign_theme_id, :email, :password,:password_confirmation,
      # from app_configuration
      :allow_ssl_in_production, :allow_ssl_in_development_and_test, :allow_ssl_in_staging, :check_for_spree_alerts, :display_currency, :hide_cents, :currency, :currency_symbol_position, :currency_decimal_mark, :currency_thousands_separator
      ]
  end
end
