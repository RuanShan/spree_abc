class SpreeThemeTables < ActiveRecord::Migration
  def self.up

    # This table contains the css specification, copied from the w3 website.
    # Ok, it also includes html elment attributes, but only the ones that can't be put in css
    # Users do not use this table.
    create_table :spree_html_attributes, :force=>true do |t|
      t.column :title,              :string,                    :null => false, :default => ""  # the name of the property
      #title is for user, css_name is for css attribute name
      t.column :css_name,              :string,                    :null => false, :default => ""  # the name of the property
      t.column :slug,               :string,                    :null => false, :default => ""  # the name of the property
      t.column :pvalues,                 :string,                    :null => false, :default => "" # comma separate list of possible values to choose from
                                 # or 0?=see below, 1=length, 2=x y, 4=t r b l,
      t.column :pvalues_desc,            :string,                    :null => false, :default => "" # comma separate list of possible values to choose from
      t.column :punits,                  :string,                    :null => false, :default => "" # the units applicable to the property if pvalues contains l1 or l2, can be %,in,cm,mm,em,ex,pt,pc,px (l=all except %). Notation is: [l|%|f][+in,cm,mm,em,ex,pt,pc,px]
      t.column :neg_ok,                  :boolean,                   :null => false, :default => false
      t.column :default_value,           :integer,  :limit => 2,     :null => false, :default => 0
      # index in pvalues of the default pvalue (it seems always 0, i.e. the first pvalue).
      # If pvalues is manual entry only then the default manual entry. 0 = we define the default value
      t.column :pvspecial,               :string,   :limit => 7,     :null => false, :default => "" # xy, trbl or inherit
    end
    add_index :spree_html_attributes, :slug, :unique => true

    create_table :spree_section_pieces,  :force=>true do |t| #sqlite do not support :options=>'ENGINE=InnoDB DEFAULT CHARSET=ascii',
      t.column :title,         :string, :limit => 100,   :null => false
      t.column :slug,          :string, :limit => 100,   :null => false
      t.column :html,                :string, :limit => 12000,   :null => false, :default => ""
      t.column :css,                 :string, :limit => 8000,   :null => false, :default => ""
      t.column :js,                  :string, :limit => 60,      :null => false, :default => "" # a comma separated list of js ids
      # indicate it is html root or not?
      t.column :is_root,        :boolean,                   :null => false, :default => false
      t.column :is_container,        :boolean,                   :null => false, :default => false
      t.column :is_selectable,       :boolean,                   :null => false, :default => false
      # could assign kinds of resources to this piece
      t.column :resources,           :string, :limit => 20,      :null => false, :default => ""
      # usage of section piece, dialog| a template need a way to find dialog section
      t.column :usage,           :string, :limit => 10,      :null => false, :default => ""
      # load by fixture, created_at,updated_at maybe nil
      t.column :created_at,           :datetime
      t.column :updated_at,           :datetime
    end
    add_index :spree_section_pieces, :slug, :unique => true

     # it is category of section_piece_params
    # 1. we want to expand&collapse
    # 2. we want to get a group of param_values, ex. general position : width, height,outer_margin, margin, border, padding.
    create_table :spree_param_categories, :force=>true do |t|
      t.column "editor_id",              :integer, :limit => 3,     :null => false, :default => 0
      t.column "position",               :integer, :limit => 3,     :null => true,  :default => 0
      t.column "slug",             :string,   :limit => 200,   :null => false, :default => ""
      t.column "is_enabled",              :boolean,                   :null => false, :default => true
      t.timestamps null: false
    end

    create_table :spree_editors, :force=>true do |t|
      t.column "slug",             :string,   :limit => 200,   :null => false, :default => ""
      t.timestamps null: false
    end

    # section_piece composite of section
    create_table :spree_sections, :force=>true do |t|
      t.column "site_id",             :integer, :limit => 3,     :null => false, :default => 0
      t.column "root_id",                :integer, :limit => 3
      t.column "parent_id",              :integer, :limit => 3
      t.column "lft",                    :integer, :limit => 2,     :null => false, :default => 0
      t.column "rgt",                    :integer, :limit => 2,     :null => false, :default => 0
      t.column "title",             :string,   :limit => 64,  :null => false, :default => ""
      t.column "slug",             :string,   :limit => 64,  :null => false, :default => ""
      t.column "section_piece_id",       :integer, :limit => 3,     :null => true,  :default => 0
      t.column "section_piece_instance", :integer, :limit => 2,     :null => true,  :default => 0
      t.column "is_enabled",              :boolean,                 :null => false, :default => true
      t.column "global_events",         :string,   :limit => 200,   :null => false, :default => ""
      t.column "subscribed_global_events",         :string,   :limit => 200,   :null => false, :default => ""
      #comma seperated event, ex. page_layout_fixed
    end
    #section instance composite of layout
    create_table :spree_page_layouts, :force=>true do |t|
      t.column "site_id",                :integer, :limit => 3,     :null => true,  :default => 0
      t.column "root_id",                :integer, :limit => 3#,     :null => true,  :default => :null
      t.column "parent_id",              :integer, :limit => 3#,     :null => true,  :default => :null
      #default value is null, acts_as_nested_set required
      t.column "lft",                    :integer, :limit => 2,     :null => false, :default => 0
      t.column "rgt",                    :integer, :limit => 2,     :null => false, :default => 0
      t.column "title",                  :string,  :limit => 200,   :null => false, :default => ""
      t.column "slug",             :string,  :limit => 200,   :null => false, :default => ""
      t.column "section_id",             :integer, :limit => 3,     :null => true,  :default => 0
      # id of sections, only root could be here.
      t.column "section_instance",       :integer, :limit => 2,     :null => false, :default => 0
      #comma seperated section context.  ex.  list,detail
      t.column "section_context",        :string,  :limit => 64,    :null => false, :default => ""
      t.column "data_source",            :string,  :limit => 32,    :null => false, :default => ""
      t.column "data_filter",            :string,  :limit => 32,    :null => false, :default => ""
      t.column "is_enabled",             :boolean,                  :null => false, :default => true
      # this node is copy from another tree, ex. center area is a layout tree, we prebuilt it for user.
      # value is layout tree's root_id.
      t.column "copy_from_root_id",              :integer,                  :null => false, :default => 0
      # it is only for root record, this layout tree is full html page.
      # there are two kinds of layout tree  full_html_page and part_html_page
      t.column "is_full_html",             :boolean,                :null => false, :default => false
      t.timestamps null: false

    end
    create_table :spree_section_piece_params, :force=>true do |t|
      t.column :section_piece_id,        :integer, :limit => 2,     :null => false, :default => 0
      t.column :editor_id,               :integer, :limit => 2,     :null => false, :default => 0
      t.column :param_category_id,       :integer, :limit => 2,     :null => false, :default => 0
      t.column :position,       :integer, :limit => 2,     :null => false, :default => 0
      # get param_value order by ssection_piece_params.position
      t.column :pclass,                  :string
      # since a html style attribute also could in css,
      # it tell where use the current param. possible value style,css,erb
      t.column :class_name,              :string,                    :null => false, :default => "" # if pclass == class, class_name = the name of the class
                    # if pclass == style, class_name = the name of the style
                    # if pclass == group, class_name = the name of the group of html attributes
                    # if pclass == db, class_name = the database object that this param represents, ex Menus, Groups, Products, ...
      t.column :html_attribute_ids,      :string,   :limit => 1000,  :null => false, :default => ""
      t.column :param_conditions,        :string,   :limit => 1000#,  :null => false, :default => ""
      t.boolean :is_editable,     :default=>true # some uneditable section piece param store the computed value.  like 'inner_height'

    end

    create_table :spree_section_params do |t|
      t.integer :section_root_id #it is section_root_id
      t.integer :section_id
      #t.integer :section_piece_id
      #t.integer :section_piece_instance
      t.integer :section_piece_param_id
      t.string  :default_value   #,   :null => false, :default => ""
      t.boolean :is_enabled,     :default=>true
      t.string :disabled_ha_ids, :limit=>255, :null => false, :default => ""
      t.timestamps null: false
    end

    # store the text used in the section. like pclass='txt'
    create_table :spree_section_texts do |t|
      t.string :lang
      t.string :body
      t.timestamps null: false
    end

    create_table :spree_template_themes, :force=>true do |t|
      t.column :site_id,              :integer, :null => true, :default => 0 # this is an id in the page_layouts table
      t.column :page_layout_root_id,               :integer, :null => false, :default => 0 # this is an id in the page_layouts table
      t.column :release_id,              :integer, :null => true, :default => 0 # this is an id in the page_layouts table
      t.column :title,                   :string,  :limit => 64,      :null => false, :default => ""  # the name of the property
      t.column :slug,                    :string,  :limit => 64,      :null => false, :default => ""  # the name of the property
      #  keep all assigned resource ids to the template, it is hash
      #  {:page_layout_id={:spree/template_file=[], :spree/taxon=[]}}
      t.column :assigned_resource_ids,   :string,  :limit => 255,     :null => false, :default => ""
      #t.column :released_at,             :datetime,:null => false,    :default => "1970-01-01 00:00:00"
      t.timestamps null: false
    end

    create_table :spree_template_releases do |t|
      t.string :name,:limit => 24,     :null => false
      t.integer :theme_id,     :null => false, :default => 0
      t.timestamps null: false
    end

    create_table :spree_param_values, :force=>true do |t|
      t.column :page_layout_root_id,      :integer, :limit => 2,     :null => false, :default => 0 # this is an root layout id in the page_layouts table
      # in param_value_event, we need get page_layout
      t.column :page_layout_id,      :integer, :limit => 2,     :null => false, :default => 0 # this is an id in the page_layouts table
      #section_param indicate section_piece instance.
      #t.column :section_id,              :integer, :limit => 2,     :null => false, :default => 0 # this is an id in the sections table
      #t.column :section_instance,        :integer, :limit => 2,     :null => false, :default => 0 # the instance of the section in the layout
      t.column :section_param_id,  :integer, :limit => 2,     :null => false, :default => 0
      t.column :theme_id,                 :integer, :limit => 2,     :null => false, :default => 0
      t.column :pvalue,                  :string, :limit => 4096 #,                   :null => false, :default => "" # the user chosen value of the corresponding default_page_param (can be utf8)
      t.column :unset,                   :string #,                   :null => false, :default => false if true ignore the pvalue and do not generate an output for this param
      t.column :computed_pvalue,         :string #,                   :null => false, :default => "" #hash in yml
      #t.column :preview_pvalue,          :string,                   :null => false, :default => ""
      # only used when pclass=themeimg, if not empty this is the name of the image to use during preview, when publishing set this to empty after renaming the file on disk.
      #t.column :preview_unset,           :string,                   :null => false, :default => false # if true ignore the pvalue and do not generate an output for this param
      t.timestamps null: false
    end
    create_table :spree_template_files do |t|
      t.integer :theme_id
      t.integer    :attachment_width
      t.integer    :attachment_height
      t.integer    :attachment_file_size
      t.string     :attachment_content_type
      t.string     :attachment_file_name
      t.datetime   :attachment_updated_at
      t.datetime :created_at
    end

  end

  def self.down
    drop_table :spree_html_attributes
    drop_table :spree_section_pieces
    drop_table :spree_param_categories
    drop_table :spree_editors
    drop_table :spree_sections
    drop_table :spree_page_layouts
    drop_table :spree_section_piece_params
    drop_table :spree_section_params
    drop_table :spree_section_texts
    drop_table :spree_template_themes
    drop_table :spree_template_releases
    drop_table :spree_param_values
    drop_table :spree_template_files

  end
end
