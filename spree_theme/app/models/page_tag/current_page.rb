# current page, it is current menu item.
# current_page -> website
#              -> template -> param_values
#                          -> menus
#                          -> named_resource (blog_posts, products)
#                          -> current_resource( product, blog_post )
#                          # those tags required current section_instance
#
# tags in page
# template.current_section.menu == template.menus.select
# template.current_section.param_values == template.param_values.select
module PageTag
  class CurrentPage < Menus::WrappedMenu

    attr_accessor :page_generator,:website_tag, :template_tag, :product_tag, :post_tag
    delegate :theme, :resource, :product, :post, :to => :page_generator
    delegate :is_preview, :released_page_path, :to => :page_generator
    delegate :design?, :to => :website_tag, :prefix=>"site"
    alias_attribute :page, :model
    alias_attribute :website, :website_tag

    def initialize(page_generator)
      self.page_generator  = page_generator
      self.website_tag = ::PageTag::WebsiteTag.new(page_generator)
      self.template_tag = ::PageTag::TemplateTag.new(page_generator)
      # it is required to generate path
      self.collection_tag = ::PageTag::Menus.new(self.template_tag)
      self.model = self.page_generator.menu #Menus::WrappedMenu required model

      # current product
      if self.page_generator.product.present?
        products_tag = Products.new( page_generator, [ page_generator.product ], self )
        self.product_tag = products_tag.wrapped_models.first
      end

      # current post
      if self.page_generator.post.present?
        posts_tag = Products.new( page_generator, [ page_generator.post ], self )
        self.post_tag = posts_tag.wrapped_models.first
      end

    end

    #title is current page title,  resource.title-page.title-website.title
    def title
      if page.meta_title.present?
        page.meta_title
      elsif home? #|| page.root?
        # do not show page name for root, for case, show all products on home page.
        # should show  page name for root,
        # for case, user click taxon root( products ) -> click a product, now current page is 'products'
        # home page point to product category root. show website.name as title.
        website.name
      elsif detail_page?
        "#{resource.name} - #{page.name} - #{website.name}"
      else
        "#{page.name} - #{website.name}"
      end
    end

    #is given section context valid to current page
    def valid_context?
      #Rails.logger.debug "valid=#{page.current_context}, self.template_tag.current_piece=#{self.template_tag.current_piece.title}"
      ret = theme.valid_context?(template_tag.current_piece.page_layout, page)
      #(self.template_tag.current_piece.context? page.current_context)
    end

    def detail_page?
      resource.present?
    end

    # when render for cart/account, should output '<%=yield %>'
    # store it in section piece would not work, controller.render_to_string would parse it.
    def reyield
      '<%=yield %>'
    end

    def agent_selector( request_user_agent )
      user_agent = UserAgent.parse request_user_agent
      # Rails.logger.debug "request_user_agent=#{request_user_agent}, user_agent=#{user_agent.to_s}"
      "#{( user_agent.browser=='Internet Explorer' ? 'ie' : user_agent.browser )} #{user_agent.version.to_s.to_i}".to_url
    end


  end

end
