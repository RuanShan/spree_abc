#负责模板的生成与发布
module Spree
  class TemplateThemeReleaser
    attr_accessor :template_theme, :page_generator, :options

    def initialize( theme, options )
      self.template_theme = theme
      self.options = options
    end


    #当前模板适用于哪些页面，即哪些上下文
    #生成模板时，序列化模板时，都需要使用
    def available_page_contexts
      if  template_theme.renderer_page?
        #                                                                     登陆界面
        [:home, :list, :detail, :cart, :account, :checkout, :thanks, :signup, :login, :password, :blog, :post, :search]
      else
        [:all]
      end
    end


    # 生成模板文件
    # params
    #   options:  page_only- do not create template_release record, rake task import_theme required it
    def release( release_attributes= {})
      if self.options[:page_only]
        template_theme.current_template_release.touch #trigger define new compiled_template_theme method
      else
        template_release = self.template_theme.template_releases.build
        template_release.name = "just a test"
        template_release.save!
        template_theme.reload # release_id shoulb be template_release.id
      end

      generate_content
      template_theme.current_template_release
    end

    #取得taxon对应的模板文件路径 /home/david/www/spree_abc/public/shops/1/....
    def page_document_path( taxon )
      context = taxon.current_context
      name = "#{context}.ehtml"
      path = self.template_theme.document_file_path( name )
    end

    def generate_content

      self.page_generator = PageTag::PageGenerator.new( self.template_theme, nil )
      #build -> generate_assets -> serialize
      self.page_generator.build( self.available_page_contexts )            # build ehtmls, ecss, ejs
      self.page_generator.generate_assets  # generate css, js
      serialize_assets(:css)
      serialize_assets(:js)
      serialize_pages()
    end


    # *specific_attribute - ehtml, ecss, html, css
    def serialize_assets(specific_attribute)
      specific_attribute_collection = [:css,:js ]
      raise ArgumentError unless specific_attribute_collection.include?(specific_attribute)
      content = page_generator.send(specific_attribute)
      if content.present?
        path = self.template_theme.document_path
        FileUtils.mkdir_p(path) unless File.exists?(path)

        path = self.template_theme.document_file_path(specific_attribute)
        open(path, 'w') do |f|  f.puts content; end
      end
    end


    # *specific_attribute - ehtml
    def serialize_pages()
      raise ArgumentError unless available_page_contexts.length == page_generator.ehtmls.length

      available_page_contexts.each_with_index{| context, i|
        content = page_generator.ehtmls[i]
        name = "#{context}.ehtml"
        path = self.template_theme.document_path
        FileUtils.mkdir_p(path) unless File.exists?(path)

        path = self.template_theme.document_file_path( name )
        open(path, 'w') do |f|  f.puts content; end
      }

    end

  end
end
