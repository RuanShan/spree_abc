require 'spree/core/environment_extension'
  module SpreeMultiSite
    class Environment
      include Spree::Core::EnvironmentExtension

      attr_accessor :site_scope_required_classes_from_other_gems, :site_scope_required_classes_with_image_from_other_gems, :preferences
      # system_top_domain is required, in middleware, we compare it with request.host,
      # it tell us to initialize site by short_name or domain.
      attr_accessor :system_top_domain

      def initialize
        #@preferences = Spree::MultiSiteConfiguration.new
        #"Spree.user_class MUST be a String or Symbol object, not a Class object."
        # it has to be in Environment, it vary in env
        @system_top_domain = "example.com"
        @site_scope_required_classes_from_other_gems = []
        @site_scope_required_classes_with_image_from_other_gems = []
      end
    end
  end
