# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_theme'
  s.version     = '3.1.0'
  s.summary     = 'spree theme'
  s.description = 'spree theme'
  s.required_ruby_version = '>= 2.2.2'

  s.author            = 'qinghe'
  s.email             = 'david@getstore.cn'
  s.homepage          = 'http://www.getstore.cn'

  #s.files         = `git ls-files`.split("\n")
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'
  spree_version = '>= 3.1.0', '< 4.0'

  s.add_dependency 'friendly_id'
  s.add_dependency 'useragent'
  s.add_dependency 'acts_as_commentable'
  s.add_dependency 'font-awesome-rails', '~> 4.7.0'
  s.add_dependency 'sitemap_generator'
  s.add_dependency 'acts-as-taggable-on'
  s.add_development_dependency 'capybara', '~> 2.6'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 3.4'
  s.add_development_dependency 'sass-rails', '~> 5.0.0'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
