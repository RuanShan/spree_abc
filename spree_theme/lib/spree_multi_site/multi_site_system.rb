# Spree::BaseController.class_eval would not work
# Spree::UserSessionsController derive from Devise::SessionsController, it included Spree::Core::ControllerHelpers
#require 'spree/core/controller_helpers/common'
#class<< Spree::Core::ControllerHelpers::Common
#  #Spree::Api::BaseController would include  MultiSiteSystem, get_layout should not in it.
#  #override original methods
#  def get_layout
#    Spree::Site.current.layout.present? ? Spree::Site.current.layout : Spree::Config[:layout]
#  end
#end

module Spree
  module MultiSiteSystem
    extend ActiveSupport::Concern

    MultiSiteContextEnum = Struct.new( :scoped, :admin_sites, :site1_themes, :free_taxon, :free )[0,1,2,3,4]

    included do
      belongs_to :site
      # rails 3.2.19
      # fix: Spree::Taxon.create!({ taxonomy_id: 0, name: 'name' }, without_protection: true) =>
      # <Spree::Taxon id: 30, name: "name", taxonomy_id: 0, site_id: nil,  depth: 0, page_context: 0, html_attributes: nil, replaced_by: 0>
      # before_create {|record| record.site_id||= Spree::Site.current.id }

      default_scope {
        # design shop create theme product, assign it to global taxon( taxon in site 1)
        # enable getting taxon from site 1
        # user import theme from design site, we support import theme with taxon.
        # enable geting taxon from design site
        if multi_site_context==MultiSiteSystem::MultiSiteContextEnum.scoped
          where(:site_id =>  Spree::Site.current.id)
        elsif ( self == Spree::Taxon || self == Spree::Taxonomy ) && multi_site_context==MultiSiteSystem::MultiSiteContextEnum.free_taxon
          where(nil)
        # first site list template themes
        elsif ( self == Spree::Product || self == Spree::Property || Spree::Image ) && multi_site_context==MultiSiteSystem::MultiSiteContextEnum.site1_themes
          where(nil)
        # first site list product images
        elsif multi_site_context=='site_product_images'
          where(nil)
        # admin sites, site.users site.stores ..
        elsif multi_site_context==MultiSiteSystem::MultiSiteContextEnum.admin_sites
          where(nil)
        else
          where(nil)
        end
      }

    end

    module ClassMethods
      def multi_site_context
        MultiSiteSystem.multi_site_context
      end
    end

    def self.multi_site_context
      Thread.current[:multi_site_context]
    end

    def self.multi_site_context=(  new_multi_site_context )
      Thread.current[:multi_site_context] = new_multi_site_context
    end

    def self.bind
      Spree::MultiSiteSystem.multi_site_context = Spree::MultiSiteSystem::MultiSiteContextEnum.scoped
    end

    def self.unbind
      Spree::MultiSiteSystem.multi_site_context = Spree::MultiSiteSystem::MultiSiteContextEnum.free
    end


    # do block with given context
    def self.with_context( new_context, &block )
      original_context = self.multi_site_context
      begin
        self.multi_site_context = new_context
        yield
      ensure
        self.multi_site_context = original_context
      end
    end

    def self.with_context_free_taxon(&block)
      with_context( MultiSiteContextEnum.free_taxon, &block )
    end

    def self.with_context_site1_themes(&block)
      with_context( MultiSiteContextEnum.site1_themes, &block )
    end

    def self.with_context_site_product_images(&block)
      with_context( 'site_product_images', &block )
    end

    def self.with_context_admin_sites(&block)
      with_context( MultiSiteContextEnum.admin_sites, &block )
    end

  end
end
