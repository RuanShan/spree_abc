#require 'active_support/concern'

module SpreeTheme
  # these are for file_theme, copy from gem themes_on_rails
  #autoload :ActionController,    'spree_theme/file_theme/action_controller'
  #autoload :ControllerAdditions, 'spree_theme/file_theme/controller_additions'

  def self.all
    Dir.glob("app/themes/*").select { |fn| !fn.start_with?('.') && File.directory?(fn) }.map { |fn| fn.split('/').last }
  end

  TEMPLATE_THEME_TABS = [:native_themes, :theme_texts, :foreign_themes]

  mattr_accessor :site_class, :taxon_class, :post_class

  def self.site_class
    #default has to be Spree::FakeWebsite, then we could test without spree_multi_site
    @@site_class ||= "Spree::Site"

    if @@site_class.is_a?(Class)
      raise "Spree.site_class MUST be a String object, not a Class object."
    elsif @@site_class.is_a?(String)
      @@site_class.constantize
    end
  end


  def self.taxon_class
    @@taxon_class ||= "Spree::Taxon"
    if @@taxon_class.is_a?(Class)
      raise "Spree.taxon_class MUST be a String object, not a Class object."
    elsif @@taxon_class.is_a?(String)
      @@taxon_class.constantize
    end
  end

  def self.post_class
    @@post_class ||= "Spree::Post"
    if @@post_class.is_a?(Class)
      raise "Spree.post_class MUST be a String object, not a Class object."
    elsif @@post_class.is_a?(String)
      @@post_class.constantize
    end
  end
end

require 'spree_multi_site'

require 'spree_core'
require 'spree_theme/sitemap_helper'
require 'spree_theme/engine'
require 'spree_theme/paper_clip_interpolate_site'
require 'spree_theme/database_theme/installer'
require 'spree_theme/file_theme/installer'
require 'spree_theme/file_theme/action_controller'
require 'spree_theme/system'
require 'spree_theme/site_helper'
require 'spree_theme/seed_helper'
require 'spree_theme/permitted_attributes'
require 'spree_theme/controller_helpers/strong_parameters'
require 'spree_theme/template_base_helper'
require 'spree_theme/client_info'
require 'spree_theme/blog_search'
