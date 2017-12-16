require 'spree/permitted_attributes'
module Spree
  module PermittedAttributes
    ATTRIBUTES_FOR_THEME=[:page_layout_attributes,:param_value_attributes,:section_piece_param_attributes,
     :section_attributes, :template_file_attributes, :template_text_attributes, :template_theme_attributes,
     :comment_type_attributes, :comment_attributes, :blog_attributes, :post_attributes, :post_file_attributes, :post_product_attributes]
    mattr_reader *ATTRIBUTES_FOR_THEME

    @@page_layout_attributes = [ :section_id,:title, :content_param, :data_source, :data_filter, :data_source_order_by, :data_source_param, :css_class, :css_class_for_js, :content_css_class, :stylish, :section_context ]
    @@param_value_attributes = [ :page_layout_root_id, :page_layout_id, :section_id ]
    @@section_piece_param_attributes = [ :editor,:param_category, :section_piece, :class_name, :pclass, :html_attribute_ids ]
    @@section_attributes = [ :section_piece_id, :title, :global_events, :subscribed_global_events,:is_enabled, :for_terminal ]
    @@template_file_attributes = [ :theme_id, :attachment, :page_layout_id, :alt ]
    @@template_text_attributes = [ :name, :body ]
    @@template_theme_attributes = [ :is_public, :site_id,:page_layout_root_id,:title, :section_root_id, :assigned_resource_ids, :for_terminal, :user_terminal_id ]
    @@product_attributes += [ :theme_id, :summary]
    @@taxon_attributes += [:page_context, :replaced_by, :is_clickable, :tooltips, :stylish]

    @@comment_type_attributes = [:name, :applies_to]
    @@comment_attributes = [:commentable_id, :commentable_type, :user_id, :comment_type_id, :comment, :cellphone, :email]

    @@store_attributes += [ logo_attributes:[:attachment], favicon_attributes:[:attachment] ]

    @@blog_attributes = [:name, :permalink]
    @@post_attributes = [ :title, :cover, :teaser, :body, :posted_at, :author, :live, :tag_list, :taxon_ids, :product_ids_string, :meta_keywords, :meta_description]
    @@post_file_attributes = [:alt, :attachment]
    @@post_product_attributes = [:post_id, :product_id, :position]

  end
end
