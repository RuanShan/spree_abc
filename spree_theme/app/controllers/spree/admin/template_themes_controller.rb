module Spree
  module Admin
    class TemplateThemesController < ResourceController #Spree::Admin::BaseController
      #before_action :load_theme, :only => [:apply, :import, :edit, :update, :release, :copy_theme]
      respond_to :html, :json, :js #update title required json

      def index
        native
      end

      #list themes
      def native
        @themes = TemplateTheme.native
        render :action=>:native
      end

      def foreign
        @themes = TemplateTheme.foreign.includes(:template_releases)
        @themes = @themes.select{|theme| theme.template_releases.present?}
      end


      #apply this theme to site
      def apply
        Spree::Store.current.apply_theme @template_theme
        respond_with(@template_theme)
      end

      begin 'design shop'

        #def prepare_import
        #end

        #copy selected theme to new theme
        def copy
          @original_theme = TemplateTheme.find(params[:id])
          #copy theme, layout, param_value
          @new_theme = @original_theme.duplicate

          respond_to do |format|
            format.html { redirect_to(admin_template_themes_url) }
          end
        end

        def release
          #create template_release before call lg.release
          if @template_theme.has_native_layout?
            @template_theme.release
          end
          if @template_theme.mobile.present?
            @template_theme.mobile.release
          end
          flash[:success] = Spree.t('notice_messages.theme_released')
          @themes = TemplateTheme.native
          render :action=>'native'
        end

      end



      protected
      def collection_actions
        [:index, :native, :foreign]
      end

      # description -  it is not using
      # params
      #   assigned_resource_ids: required, a hash, key is page_layout_id
      #     ex. {"30"=>[""], "3"=>[""]}
      #   template_files: required, a array of template_file attributes
      #def import
      #  #FIXME support config template when import theme
      #  #template_files = params[:template_files].collect{|file| TemplateFile.new( file) }.select{|file| file.attachment.present? }
      #  #assigned_resource_ids = Hash[ params[:assigned_resource_ids].collect{|key,val|
      #  #   [key.to_i,{ @template_theme.get_resource_class_key(SpreeTheme.taxon_class) => val.select(&:present?).collect(&:to_i)}]
      #  #}]
      #  #new_theme_attributes = { :assigned_resource_ids=>assigned_resource_ids,
      #  #  :template_files => template_files
      #  #}
      #  imported_theme = @template_theme.import( new_theme_attributes = {} )
      #  if imported_theme.present?
      #    flash[:success] = Spree.t('notice_messages.theme_imported')
      #  else
      #    flash[:success] = Spree.t('notice_messages.theme_not_imported')
      #  end
      #  respond_to do |format|
      #    format.html { redirect_to(foreign_admin_template_themes_url) }
      #  end
      #end

    end
  end
end
