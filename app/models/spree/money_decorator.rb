#encoding:utf-8
Spree::Money.class_eval do
  # fix price.to_html =>元 12.00  ¥12.00
  def to_html_with_cny_symbol(options = { :html => true,:symbol=>true })
     to_html_without_cny_symbol( options )
  end
  alias_method_chain :to_html,:cny_symbol  
end