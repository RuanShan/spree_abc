Spree::PageLayoutsController.class_eval do
  #store could preview native template theme
  before_action :authorize_site

  def authorize_site
    # Site.current.god? would not work, god site loaded for unexist domain
    unless @is_designer
      redirect_to 'http://'+Spree::Store.god.subdomain, status: :moved_permanently
      #raise CanCan::AccessDenied.new("Not authorized!", :access, Site)
    end
  end
end

Spree::TemplateThemesController.class_eval do
  #store could preview native template theme
  #before_action :authorize_site

  #def authorize_site
  #  # Site.current.god? would not work, god site loaded for unexist domain
  #  unless Spree::Store.current.designable?
  #    redirect_to 'http://'+Spree::Store.god.subdomain, status: :moved_permanently
  #    #raise CanCan::AccessDenied.new("Not authorized!", :access, Site)
  #  end
  #end
end

Spree::SitesController.class_eval do
  #only www.tld could access this controller
  before_action :authorize_site
  def authorize_site
    #Rails.logger.debug "-- request.host = #{request.host}"
    # Site.current.god? would not work, god site loaded for unexist domain
    unless request.host.end_with? Spree::Site.system_top_domain
      redirect_to 'http://'+Spree::Store.god.subdomain, status: :moved_permanently
      #raise CanCan::AccessDenied.new("Not authorized!", :access, Site)
    end
  end
end
