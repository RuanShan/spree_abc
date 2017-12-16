source 'https://gems.ruby-china.org'
#source 'https://rubygems.org'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead:
# ruby '2.2.4'

gem 'rails', '~>5.1'

gem 'mysql2'

# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

#gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Deploy with Capistrano
# gem 'capistrano'

gem 'turbolinks', '~> 2.5.3'
gem 'jquery-turbolinks'

eval(File.read(File.dirname(__FILE__) + '/common_spree_dependencies.rb'))
#support rich_editor
gem 'ckeditor'
gem 'spree_editor',  github: "spree/spree_editor", branch: "master"

#gem 'spree_related_products', github: 'RuanShan/spree_related_products', branch: "3-1-stable"
# gem 'sprangular',   path: './sprangular'
#'bundle update spree_multi_site' to update gem
# bundle config require specified branch, or warning message as below
# Cannot use local override for spree_multi_site at ../spree_multi_site because :branch is not specified in Gemfile. Specify a branch or use `bundle config --delete` to remove the local override

#gem 'spree_multi_site',   path: './spree_multi_site'

# Use SCSS for stylesheets,  spree_theme/spree_devise_auth required
#gem 'spree_multi_site',   path: './spree_multi_site'
gem "acts_as_commentable"
gem 'acts-as-taggable-on'
gem 'useragent'
gem "font-awesome-rails"
gem 'spree_theme',   path: './spree_theme'

#activemerchant_patch_for_china requried
gem 'ruby-hmac' #http://ryanbigg.com/2009/07/no-such-file-to-load-hmac-sha1/
#only specify it here, then could use ActiveMerchant::Billing::Integrations::Alipay::Helper directly
gem 'alipay'
#gem 'offsite_payments'
#gem 'spree_alipay',   github:  "RuanShan/spree_alipay", branch: "master"

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
gem 'spree_china_checkout',   path: './spree_china_checkout'
#gem 'spree_essential_blog',   path: './spree_essential_blog'

#gem 'spree_pingpp',   path: './spree_pingpp'

gem 'wechat'
#gem 'spree_omniauth',   path: './spree_omniauth'

# copy from https://github.com/RuanShan/spree_flexi_variants/tree/2-1-stable
# gem 'spree_flexi_variants',   path: './spree_flexi_variants'

# copy from https://github.com/spree-contrib/spree_comments/tree/2-0-stable
#gem 'spree_comments',   path: './spree_comments' # it is moved into spree_theme
gem 'paperclip_oss_storage',   github: 'RuanShan/paperclip_oss_storage', branch: 'master'

gem 'spree_mail_settings',   github: 'RuanShan/spree_mail_settings', branch: 'master'
#
gem 'bootstrap-sass', '~> 3.3.6'
gem 'autoprefixer-rails'

gem 'activerecord-session_store'

#gem 'proclaimer', github: 'RuanShan/proclaimer', branch: 'master'
#gem 'sidekiq'
gem 'exception_notification'
#gem 'spree_social', github: 'spree-contrib/spree_social', branch: 'master'
#gem 'omniauth'
#gem "omniauth-wechat-oauth2", git: 'git@github.com:yangsr/omniauth-wechat-oauth2.git'

# memcached 1.4+
# Dalli, kgio is for Dalli
#gem 'kgio'
#gem 'dalli'
gem 'sitemap_generator'


group :test, :development do
  gem 'sqlite3'
  #gem 'mail_view'  #, :git => 'https://github.com/37signals/mail_view.git'
end

group :test do
  gem 'capybara', '~> 2.4'
  gem 'database_cleaner', '~> 1.3'
  gem 'email_spec'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'launchy'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails', '~> 3.1.0'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'webmock', '1.8.11'
  gem 'poltergeist', '1.5.0'
  gem 'timecop'
  gem 'with_model'
end

group :development do
  gem 'pry-rails'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'byebug'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'wdm', '>= 0.1.0' if Gem.win_platform?
