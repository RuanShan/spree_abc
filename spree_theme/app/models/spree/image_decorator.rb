Spree::Image.class_eval do
  #override attachement[:path]
  attachment_definitions[:attachment][:url] = '/shops/:rails_env/:site/products/:id/:basename_:style.:extension'
  attachment_definitions[:attachment][:path] = ':rails_root/public/shops/:rails_env/:site/products/:id/:basename_:style.:extension'
  attachment_definitions[:attachment][:styles] = { mini: '48x48>', small: '100x100>', product: '240x240>', medium: '350x350>', large: '600x600>' }

  extend SpreeMultiSite::PaperclipAliyunOssHelper

end

Spree::Taxon.class_eval do
  #override attachement[:path]
  #attachment_definitions[:icon][:url] = '/shops/:rails_env/:site/taxons/:id/:style/:basename.:extension'
  #attachment_definitions[:icon][:path] = ':rails_root/public/shops/:rails_env/:site/taxons/:id/:style/:basename.:extension'
  #extend SpreeMultiSite::PaperclipAliyunOssHelper
end

#Spree::Post.class_eval do
#  #override attachement[:path]
#  attachment_definitions[:cover][:url] = '/shops/:rails_env/:site/posts/:id/:basename_:style.:extension'
#  attachment_definitions[:cover][:path] = ':rails_root/public/shops/:rails_env/:site/posts/:id/:basename_:style.:extension'
#  extend SpreeMultiSite::PaperclipAliyunOssHelper
#end

#Spree::TemplateFile.class_eval do
#  attachment_definitions[:attachment][:url] = "/shops/:rails_env/:site/:class/:id/:basename_:style.:extension"
#  attachment_definitions[:attachment][:path] = ":rails_root/public/shops/:rails_env/:site/:class/:id/:basename_:style.:extension"
#  extend SpreeMultiSite::PaperclipAliyunOssHelper
#end

# these class do not define in spree and spree_multi_site, we should specify in
# site_scope_required_classes_with_image_from_other_gems, or cause error uninitialized constant
# eventhough spree_multi_site is in spree_abc, tests in spree_multi_site would not work.
#  [['Spree::Post',:cover],['Spree::TemplateFile',:attachment]]
Rails.application.config.spree_multi_site.site_scope_required_classes_with_image_from_other_gems.each do | klass, attachement_name_symbol|
#  extra_class.class_eval do
#    include Spree::MultiSiteSystem
#  end
  klass.constantize.class_eval do
    # Spree::Post => 'posts'  class.to_s.demodulize.underscore.pluralize
    attachment_definitions[attachement_name_symbol][:url] = "/shops/:rails_env/:site/:class/:id/:basename_:style.:extension"
    attachment_definitions[attachement_name_symbol][:path] = ':rails_root/public/shops/:rails_env/:site/:class/:id/:basename_:style.:extension'
    extend SpreeMultiSite::PaperclipAliyunOssHelper
  end
end
