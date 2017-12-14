Spree::ShippingMethod.class_eval do
  # fix strange problem
  # ttrs = {"name"=>"顺丰 Ground", "display_on"=>"", "admin_name"=>"", "tracking_url"=>"", "calculator_type"=>"Spree::Calculator::Shipping::FlatPercentItemTotal", "calculator_attributes"=>{"preferred_amount"=>"5.0", "preferred_currency"=>"USD", "id"=>"1"}}
  # self.update_attributes(attrs) 
  # raise  Couldn't find Spree::Calculator with ID=1 for Spree::ShippingMethod with ID=3
  # from /home/david/.rvm/gems/ruby-1.9.3-p448@spree_abc/gems/activerecord-3.2.17/lib/active_record/nested_attributes.rb:487:in `raise_nested_attributes_record_not_found'
  accepts_nested_attributes_for :calculator, :update_only=>true
end

