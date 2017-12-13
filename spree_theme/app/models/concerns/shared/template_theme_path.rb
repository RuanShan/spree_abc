module Shared
  module TemplateThemePath
    extend ActiveSupport::Concern
      class_methods do
        def complied_method_name_prefix_regex
          /\A_cttm_at[\d]+_/
        end
      end
      # * params
      #   * usage - may be [css, js, ruby, ehtml, card.ehtml, home.ehtml, list.ehtml ..]
      def file_name(usage)
        usage  = usage.to_s unless usage.is_a? String
        if usage =~ /[\w]+\.ehtml/
          name = usage.split('.').first
          "l#{original_page_layout_root.id}#{name}.html.erb"
        elsif usage =~ /ehtml/
          "l#{original_page_layout_root.id}.html.erb"
        else
          "l#{original_page_layout_root.id}.#{usage}"
        end
      end

      # folder name 'layouts' is required, rails look for layout in folder named 'layouts'
      def path
        # self.id is not accurate, it may use imported theme of design site.
        # on other side, design site may release template first time. current_template_release = nil
        if self.current_template_release.present?
          File.join( File::SEPARATOR+'layouts', "t#{self.current_template_release.theme_id}_r#{self.release_id}")
        else
          File.join( File::SEPARATOR+'layouts', "t#{self.id}_r#{self.release_id}")
        end
      end

      def document_path
        File.join( original_template_theme.store.document_path, self.path)
      end

      # * params
      #   * targe - could be css, js
      # * return js or css document file path, ex /shops/development/1/layouts/t1_r1/l1_t1.css
      def file_path( target )
        # theme.site do not work.
        File.join( original_template_theme.store.path, self.path, file_name(target))
      end

      def layout_path
        document_file_path( 'ruby' )
      end

      def document_file_path( target )
        File.join( document_path, file_name(target) )
      end
    # compliled template theme method format
    # _cttm_at{current_template_release.updated_at.to_i}_#{current_template_release.theme_id}
    # method for generate page, consider template theme may refer to another template_theme in design shop
    def complied_method_name
      method_name = "#{complied_method_name_prefix}#{current_template_release.theme_id}"
    end


    def complied_method_name_prefix
      "_cttm_at#{current_template_release.updated_at.to_i}_"
    end


  end
end
