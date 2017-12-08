class Spree::BlogConfiguration < Spree::Preferences::Configuration
  
  preference :disqus_shortname,  :string, :default => ''

  preference :admin_posts_per_page, :integer, default: 10  
  preference :posts_per_page, :integer, default: 12
  
end
