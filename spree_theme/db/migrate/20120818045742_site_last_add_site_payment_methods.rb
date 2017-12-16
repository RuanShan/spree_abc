class SiteLastAddSitePaymentMethods < ActiveRecord::Migration
  # in this file add site_id after all table complete.
  def up
    table_name = Spree::PaymentMethod.connection.table_exists?(:payment_methods) ? :payment_methods : :spree_payment_methods
    add_column table_name, :site_id, :integer
    table_name = Spree::LogEntry.connection.table_exists?(:log_entries) ? :log_entries : :spree_log_entries
    add_column table_name, :site_id, :integer
    table_name = Spree::StateChange.connection.table_exists?(:state_changes) ? :state_changes : :spree_state_changes
    add_column table_name, :site_id, :integer

  end

  def down
     remove_column Spree::PaymentMethod.table_name, :site_id
     remove_column Spree::LogEntry.table_name, :site_id
     remove_column Spree::StateChange.table_name, :site_id

  end
end
