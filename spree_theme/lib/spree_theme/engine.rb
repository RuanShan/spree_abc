module SpreeTheme
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_theme'

    # copy from engine spree_multi_site
    config.spree_multi_site = SpreeMultiSite::Environment.new

    initializer "spree.multisite.add_middleware" do |app|
      app.middleware.use SpreeMultiSite::Middleware
    end

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/models/spree/calculator)
    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree.promo.register.promotion.calculators' do |app|
      app.config.spree.calculators.promotion_actions_create_adjustments << Spree::Calculator::RelatedProductDiscount
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      #https://github.com/spree-contrib/spree_sitemap
      SitemapGenerator::Interpreter.send :include, SpreeTheme::SitemapHelper
      if defined? SitemapGenerator::LinkSet
        SitemapGenerator::LinkSet.send :include, SpreeTheme::SitemapHelper
      end
    end

    # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
    initializer "spree.assets.precompile", :group => :all do |app|
      app.config.assets.precompile += %w[
        store/spree_theme.*
        jquery.jstree/themes/spree2/style.css
      ]


    end

    ## copy from themes_on_rails
    initializer 'themes_on_rails.load_locales' do |app|
      app.config.i18n.load_path += Dir[Rails.root.join('app/themes/*', 'locales', '**', '*.yml').to_s]
    end

    initializer 'themes_on_rails.assets_path' do |app|
      Dir.glob("#{SpreeTheme::Engine.root}/app/themes/*/assets/*").each do |dir|
        app.config.assets.paths << dir
      end

    end

    initializer 'themes_on_rails.precompile' do |app|
    #  # for file theme assets
      app.config.assets.precompile << Proc.new do |path, fn|
        if fn =~ /app\/themes/
          basename = path.split('/').last
          if !%w(.js .css).include?(File.extname(path))
            true
          elsif path =~ /^[^\/]+\/all((_|-).+)?\.(js|css)$/
            # 1. don't allow nested: theme_a/responsive/all.js
            # 2. allow start_with all_ or all-
            # 3. allow all.js and all.css
            true
          else
            false
          end
        end
      end
    end


    config.to_prepare &method(:activate).to_proc
  end
end
