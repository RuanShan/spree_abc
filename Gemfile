#source 'http://rubygems.org'
source 'http://ruby.taobao.org/'

gem 'mysql2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

#gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
#group :test, :development do
#  gem "rspec-rails", "~> 2.0"
#  gem "capybara"
#end
gem 'select2-rails'

gem 'ruby-hmac' #http://ryanbigg.com/2009/07/no-such-file-to-load-hmac-sha1/

gem 'spree', :github => "spree/spree", :branch => "2-2-stable"

# bundle config --local local.spree_simple_dash ../spree_simple_dash, using local for development 

# referer to https://github.com/spree/spree/issues/2013
gem 'spree_auth_devise', :github => "spree/spree_auth_devise", :branch => "2-2-stable"
#gem 'daemons'
#gem 'delayed_job_active_record'
#'bundle update spree_multi_site' to update gem
# bundle config require specified branch, or warning message as below
# Cannot use local override for spree_multi_site at ../spree_multi_site because :branch is not specified in Gemfile. Specify a branch or use `bundle config --delete` to remove the local override
  
gem 'spree_multi_site',   :path => './spree_multi_site'

#gem "friendly_id" # spree has already required, spree_theme require it.
gem 'spree_theme',   :path => './spree_theme'
#only specify it here, then could use ActiveMerchant::Billing::Integrations::Alipay::Helper directly
gem 'activemerchant', :require => 'active_merchant'
gem 'activemerchant_patch_for_china' #support alipay
gem 'spree_alipay',   :github => "RuanShan/spree_alipay", :branch=>"master"
gem 'spree_china_checkout',   :path => './spree_china_checkout'

#support rich_editor 
gem 'spree_editor',  :github => "spree/spree_editor", :branch=>"2-2-stable"
gem 'tinymce-rails-langs'


group :test, :development do
  gem 'mail_view'  #, :git => 'https://github.com/37signals/mail_view.git'
end

group :test do
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'capybara'
  gem 'capybara-accessible'  
  gem 'webmock'
end
#execjs need js runtime
gem 'therubyracer' 

group :development do
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem "rails-erd"
end


