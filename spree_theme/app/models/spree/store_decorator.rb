Spree::Store.class_eval do
  # Do not use default_scope, in view template_theme/foreign, we want to get store of template_theme.
  # include Spree::MultiSiteSystem
  belongs_to :site

  clear_validators!
  class << self
    #override original current
    def current(domain = nil)
      #UnknownStore.instance is for test only
      ::Thread.current[:spree_store] || UnknownStore.instance
    end

    def current=(some_store)
      ::Thread.current[:spree_store] = some_store
    end

    def by_domain( domain )
      current_store = if domain.is_a? String
        if domain.end_with? Spree::Site.system_top_domain
          # 域名示例
          # getstore.cn，www.getstore.cn, test.getstore.cn
          if domain == Spree::Site.system_top_domain
            self.god
          else
            short_name = domain.split('.').first
            self.find_by_code(short_name)
          end
        else
          self.by_url(domain).first
        end
      else
        self.default
      end
      current_store
    end

    # we can not easily modify cookies except firefox, we'll add default_site for debug page on other browser.
    # we could set default site for missing site as well.
    def default
      # Fix Spree::Store.default.persisted?
      where( default: true ).first || new
    end

    def god
      where( code: 'www' ).first
    end
  end

  # current site'subdomain => short_name.tld
  def subdomain
    code + '.' + Spree::Site.system_top_domain
  end

  # it is god(first) store
  def god?
    self == self.class.god
  end

  #app_configuration require site_id
  class UnknownStore
    include Singleton
    def id
      0
    end

    def site
      #app_configuration require site_id
      Struct.new(:id).new(0)
    end
  end
end
