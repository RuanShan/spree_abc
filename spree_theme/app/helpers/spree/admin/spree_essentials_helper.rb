module Spree::Admin::SpreeEssentialsHelper
  
  def inside_contents_tab?
    @inside_contents_tab ||= !request.fullpath.scan(Regexp.new(extension_routes.join("|"))).empty?
  end
  
  def contents_tab
    content_tag :li, :class => inside_contents_tab? ? 'selected' : nil do
      link_to I18n.t('spree.admin.shared.contents_tab.content'), extension_routes.first
    end
  end
  
  def mini_cover( post )
    options = {:alt=> 'post mini image'}
    if post.cover.present?
      image_tag post.cover.url(:mini), options      
    else
      image_tag "noimage/mini.png", options
    end

  end
  
private
  
  def extension_routes
    @extension_routes ||= SpreeEssentials.essentials.map { |key, cls|
      route = cls.tab[:route] || "admin_#{key}"
      send("#{route}_path") rescue "##{key}"      
    }    
  end
  
end
