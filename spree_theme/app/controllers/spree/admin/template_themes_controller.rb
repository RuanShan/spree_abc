module Spree
  module Admin
    class TemplateThemesController < ResourceController #Spree::Admin::BaseController
      #before_filter :load_theme, :only => [:apply, :import, :edit, :update, :release, :copy_theme]

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

      # params
      #   assigned_resource_ids: required, a hash, key is page_layout_id
      #     ex. {"30"=>[""], "3"=>[""]} 
      #   template_files: required, a array of template_file attributes                        
      def import
        template_files = params[:template_files].collect{|file| TemplateFile.new( file) }.select{|file| file.attachment.present? }
        
        assigned_resource_ids = Hash[ params[:assigned_resource_ids].collect{|key,val|
           [key.to_i,{ @template_theme.get_resource_class_key(SpreeTheme.taxon_class) => val.select(&:present?).collect(&:to_i)}]
        }]
        new_theme_attributes = { :assigned_resource_ids=>assigned_resource_ids,
          :template_files => template_files
        }
        
        imported_theme = @template_theme.import( new_theme_attributes )
        if imported_theme.present?
          flash[:success] = Spree.t('notice_messages.theme_imported')
        else
          flash[:success] = Spree.t('notice_messages.theme_not_imported')
        end

        
        respond_to do |format|
          format.html { redirect_to(foreign_admin_template_themes_url) }
        end    
      end
      
      #apply this theme to site
      def apply
        SpreeTheme.site_class.current.apply_theme @template_theme                    
        @themes = TemplateTheme.native          
        render :action=>'native' 
      end

      begin 'design shop'
        
        def prepare_import
          logger.debug "action=#{action.inspect}"
        end
        
        #copy selected theme to new theme
        def copy
          @original_theme = TemplateTheme.find(params[:id])
          #copy theme, layout, param_value
          @new_theme = @original_theme.copy_to_new
          
          respond_to do |format|
            format.html { redirect_to(admin_template_themes_url) }
          end    
        end

        def release
          #create template_release before call lg.release    
          if @template_theme.has_native_layout?     
            @template_theme.release
          end
          @themes = TemplateTheme.native          
          render :action=>'native' 
        end
        
      end
      protected
      def collection_actions
        [:index,:native, :foreign]
      end
      
      #def find_resource
      #  logger.debug "action=#{action.inspect}"
      #  if parent_data.present?
      #    parent.send(controller_name).find(params[:id])
      #  elsif ['import', 'prepare_import'].include? action
      #    
      #  else
      #    model_class.find(params[:id])
      #  end
      #end
    end
  end
end
