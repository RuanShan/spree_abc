class SiteMoveAppConfigurationToSite < ActiveRecord::Migration
  def change
    add_column :spree_sites, :allow_ssl_in_production, :boolean, :default=>false
    add_column :spree_sites, :allow_ssl_in_development_and_test, :boolean, :default=>false
    add_column :spree_sites, :allow_ssl_in_staging, :boolean, :default=>false
    add_column :spree_sites, :check_for_spree_alerts, :boolean, :default=>false
    
    add_column :spree_sites, :display_currency, :boolean, :default=>false
    add_column :spree_sites, :hide_cents, :boolean, :default=>false
    
    add_column :spree_sites, :currency, :string, :default=>'CNY'    
    add_column :spree_sites, :currency_symbol_position, :string, :default=>"before"
    add_column :spree_sites, :currency_decimal_mark, :string, :default=>"."
    add_column :spree_sites, :currency_thousands_separator, :string, :default=>","    
  end


end
