# mainly COPY from spree/core/product_duplicator
# tables
# site_related_tables:    template_theme,
# site_unrelated tables:  page_layout, param_value, template_file



module Spree
  class TemplateThemeDuplicator
    attr_accessor :original_template_theme
    def initialize( template_theme)
      self.original_template_theme = template_theme
    end

    def duplicate
      #page_layout tree, template_files, template_theme save together.
      new_template_theme = duplicate_template_theme
      new_template_theme.page_layout_root = duplicate_page_layout( new_template_theme )
      new_template_theme.template_files = duplicate_template_files( new_template_theme )
      new_template_theme.save!
      # page_layout_root is nested_set, it is not same as template_files
      # new_template_theme.page_layout_root_id is 0.
      # new_template_theme.save => new_template_theme.page_layout_root.save => new_template_theme.page_layout_root.template_theme.save
      # so in fact new_template_theme is saved first, then page_layout_root.save ...
      # even new_template_theme saved and page_layout_root saved
      # we need to fix new_template_theme.page_layout_root_id
      new_template_theme.update_attributes!( page_layout_root_id: new_template_theme.page_layout_root.id )
      handle_param_values( new_template_theme )
      handle_template_resources(new_template_theme )
      new_template_theme
    end

    protected

    def duplicate_template_theme
      new_template_theme = original_template_theme.dup
      new_template_theme.store_id = Spree::Store.current.id
      new_template_theme.release_id = 0 # new copied theme should have no release
      new_template_theme.page_layout_root_id = 0
      new_template_theme.copy_from_id = original_template_theme.id
      new_template_theme
    end

    def duplicate_page_layout( new_template_theme )
      page_layout_root = original_template_theme.page_layout_root
      h = { page_layout_root => page_layout_root.dup } #we start at the root
      ordered = page_layout_root.descendants
      #clone subitems
      ordered.each do |item|
        h[item] = item.dup
      end
      #resolve relations
      ordered.each do |item|
        cloned = h[item]
        item_parent = h[item.parent]
        item_parent.children << cloned if item_parent
      end
      h.each_pair{|item, cloned|
        cloned.copy_from_id = item.id
        cloned.template_theme = new_template_theme
      }
      cloned_branch = h[page_layout_root]
    end

    def duplicate_template_files( new_template_theme )
      #copy template_files
      new_template_files = original_template_theme.template_files.map{|template_file|
        new_template_file = template_file.dup
        new_template_file.assign_attributes(:attachment => template_file.attachment.clone)
        new_template_file.template_theme = new_template_theme
        new_template_file
      }
    end

    def handle_param_values( new_template_theme )
      original_theme_id = original_template_theme.id
      new_theme_id = new_template_theme.id
      #copy param values
      #INSERT INTO tbl_temp2 (fld_id)    SELECT tbl_temp1.fld_order_id    FROM tbl_temp1 WHERE tbl_temp1.fld_order_id > 100;
      table_name = ParamValue.table_name

      table_column_names = ParamValue.column_names
      table_column_names.delete('id')
      table_column_values  = table_column_names.dup
      # method fix_related_data_for_copied_theme handle theme_id, page_layout_root_id
      table_column_values[table_column_values.index('page_layout_root_id')] = new_template_theme.page_layout_root_id
      table_column_values[table_column_values.index('theme_id')] = new_template_theme.id
      #table_column_values[table_column_values.index('created_at')] = "'#{created_at.utc.to_s(:db)}'" #=>'2014-08-20 02:48:23'
      #copy param value from origin to new.
      sql = %Q!INSERT INTO #{table_name}(#{table_column_names.join(',')}) SELECT #{table_column_values.join(',')} FROM #{table_name} WHERE  (theme_id =#{original_theme_id})!
      ActiveRecord::Base.connection.execute(sql)

      new_page_layout_nodes = new_template_theme.page_layouts
      new_page_layout_nodes.each{|node|
        ParamValue.where( :theme_id=>new_theme_id, :page_layout_id=>node.copy_from_id  ).
          update_all( :page_layout_id=> node.id  )

      }

    end

    def handle_template_resources( new_template_theme )
      obsolete_template_resources = new_template_theme.template_resources
      new_page_layout_nodes = new_template_theme.page_layouts
      new_page_layout_nodes.each{|node|
        template_resource = obsolete_template_resources.select{|template_resource| template_resource.page_layout_id== node.copy_from_id }.first
        if template_resource.present?
          #change page_layout_key, update one of them is done.
          template_resource.update_attribute!(:page_layout_id, node.id )
        end
      }
      # after page_layout_key updated,  confirm template_resource existing.
      # reload new_template_theme which may be from other store.
      new_template_theme.template_resources.select{|template_resource| template_resource.source.nil? }.each(&:destroy!)
    end
  end
end
