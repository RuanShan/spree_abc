# section param effect on content, we use data_source_param, such as pagination
# section param effect on css, we use content_param, such as clickable, image size


# content_param: 内容参数 columns=n/clickable=1/image_size
# css_class_for_js: css 类， 应用于js。
# css_class: css 类， 应用于css。 CSS bootstrap .col-xs-n, .container, .container-fluid
# content_css_class(css_class_for_font): 字体图标 awesomefont/glyphicon,
#   TODO: 定制font-awesome， css_class 可以支持这个功能。
# data_source： 数据源类型， 菜单/产品/文章
# data_source_param: 数据源参数 per_page
# 一个模板可以定义产品列表/文章列表的多个显示样式，每个页面可以选择适用的样式。
# stylish: 样式号码，用于实现上述需求，
#   page_layout 和 taxon 分别有自己的样式号码,即页面声明的样式号码与模板的样式号码一致时，显示相应模板
#   样式号码为0时，表示通用，即这个section适用任意页面，无论这个页面的stylish设置为多少



module Spree
  class PageLayout < ActiveRecord::Base
    include Spree::Context::Base
    include Spree::AssignedResource::SectionResourceGlue

    PaginationStyle = Struct.new( :page_links, :pn_links, :infinitescroll, :more, :none )['1', 'pn', 'i', 'm', '0']

    # depth is massed up while duplicate full set. so we disable it here.
    acts_as_nested_set :scope=>['template_theme_id' ], :depth_column=>'notallowed', :dependent=> :destroy # scope is for :copy, no need to modify  lft, rgt.
    belongs_to :section
    belongs_to :template_theme, :class_name =>'Spree::TemplateTheme'
    # has_many :themes, :class_name => "TemplateTheme",:primary_key=>:root_id,:foreign_key=>:page_layout_root_id
    has_many :param_values, dependent: :delete_all
    # this table is used by other site, should not use scope here
    # we want title to support multi-language, so disable friendly_id
    # friendly_id :title, :use => :slugged
    has_many :sections, :class_name =>'Section', :foreign_key=>:root_id, :primary_key=>:section_id
    has_many :section_pieces, :through=>:sections
    # remove section relatives after page_layout destroyed.
    # before_destroy :remove_section
    before_validation :set_default_values

    delegate :is_html_root?, :is_container?, :is_image?, :is_zoomable_image?, to: :section

    scope :full_html_roots, ->{ where(:is_full_html=>true,:parent_id=>nil) }
    #attr_accessible :section_id,:title
    attr_accessor :current_contexts, :inherited_contexts

    class << self
      # create component, it is partial layout, no html body, composite of some sections.
      #notice: attribute section_id, title required
      # section.root.section_piece_id should be 'root'
      #def create_layout(section, title, attrs={})
      #  layout = create!(:section_id=>section.id) do |obj|
      #    obj.title = title
      #    obj.attributes = attrs unless attrs.empty?
      #    obj.section_instance = 1
      #    obj.is_full_html = section.section_piece.is_root?
      #  end
      #  layout.update_attribute("root_id",obj.id)
      #  layout
      #end


      # user copy decendants of a layout to new root layout while user copy theme to new theme.
      # since copy to new root, there is no section_instance confliction.
      #def copy_decendants_to_new_parent(new_parent, original_parent, ordered_nodes)
      #  original_children =  ordered_nodes.select{|node| node.parent_id == original_parent.id }
      #  for node in original_children
      #    new_node = node.dup
      #    new_node.parent_id = new_parent.id
      #    new_node.root_id = new_parent.root_id
      #    new_node.save!
      #    if node.has_child?
      #      copy_decendants_to_new_parent(new_node, node, ordered_nodes )
      #    end
      #  end
      #  # copy_from_root_id means we have copied all decendants from that tree.
      #  if new_parent.root?
      #    where( root_id: new_parent.id ).update_all(["copy_from_root_id=?",original_parent.id])
      #  end
      #end

      # * description - copy :page_layout_tree whole tree
      # * params
      # *   ordered_nodes -  whole tree node collection, it is ordered by left
      # * return - new ordered nodes
      #def copy_to_new(ordered_nodes, new_attributes = nil)
      #  #create new root first, get new root id.
      #  original_root = ordered_nodes.first
      #  new_layout = original_root.dup
      #  new_layout.root_id = 0 # reset the lft,rgt.
      #  new_layout.save!
      #  new_layout.update_attribute("root_id", new_layout.id)
      #  copy_decendants_to_new_parent(new_layout, original_root,  ordered_nodes)
      #  new_layout.reload.self_and_descendants
      #end
    end

      # verify :come_contexts valid to :target_contexts
      #   home is special list
      # ex.  [:cart]  is valid to [:either]  taxon  <->  page_layout
      #      [:cart]  is valid to [:account, :checkout, :thankyou, :cart]
      #      [:cart]  is invalid to [:account]
      #      [:list]  is invalid to [:home]
      #      [:home]  is invalid to [:list]
      #      [:either] is valid to [:home]    page_layout <-> page_layout, called by update_section_context

      def self.verify_contexts( some_contexts, target_contexts )
        some_contexts = [some_contexts] unless some_contexts.kind_of?( Array )
        #Rails.logger.debug "some_contexts=#{some_contexts.inspect}, target_contexts=#{target_contexts}, [ContextEnum.either]=#{[ContextEnum.either].inspect}, is_valid = #{ret}"
        ret = ( some_contexts==[ContextEnum.either] || target_contexts==[ContextEnum.either] || (target_contexts&some_contexts)==some_contexts ) || (some_contexts==[ContextEnum.search] && target_contexts.include?(ContextEnum.list))
        #|| (some_contexts==[ContextEnum.home]&&target_contexts.include?(ContextEnum.list))
      end

    # get section css selector, then replace html with new rendered content
    # it is same as TemplateTag/WrappedPageLayout, consider merge them.
    #def section_selector
    #  "s_#{self.id}_#{self.section_id}"
    #end
    def duplicator
      PageLayoutDuplicator.new( self.root )
    end

    begin ' page_layout content'
      # a page_layout tree could be whole html or partial html, it depend's on self.section.section_piece.is_root?,
      # it is only for root.

      # use as css class, later js select elements by those class
      def effects
        if @effect_classes.nil?
          clickable = get_content_param_by_key( :clickable )
          param_value = get_content_param()
          @effect_classes =[]
          Section::MouseEffect.each_pair{|effect,val|
            #   00001000
            # & 00001111  => val
            if( (param_value & Section::MouseEffectMask) == val)
              @effect_classes << ( clickable ? "click_effect_#{effect}" : "hover_effect_#{effect}" )
            end
          }
        end
        @effect_classes
      end

      # a section could link to ....  ex. font-awesome  could link to home
      def href
          some_context = get_content_param_by_key( :context )
          SpreeTheme.taxon_class.get_route_by_page_context( some_context )
      end

      def has_extra_selector?
        #child1,child2...              data1,data2...                                          zoomable                  columns>0, data_first,data_last  infinitescroll
        self.effects.present? || parent.effects.present? || parent.data_source.present? || self.get_content_param > 0 || parent.get_content_param > 0 || self.data_source_param.present?
      end


      # * description - content_param is integer, each bit has own mean for each section.
      # * params
      #   * key - clickable, taxon_name, render as <a> or <span>?
      #         - image-size,  main product image size, [small|product|large|original]
      #         - columns, eliminate margin-right of last column - bit3,
      def get_content_param_by_key(key)
        # bit 1, 2,3,4,5,6,7,8,9
        #     2+4+8+16+32+64+128 = 254
        default_truncate_at = 100;
        # content_param int(11) 4bytes 4*8=32bits
        case key
        when :clickable                                   # apply to container/taxon/product/post attributes
          # generate <a>
          # bit 1, product:name,image, taxon:name,icon
          get_content_param&1 >0
        when :hoverable                                   # apply to container/taxon/product/post attributes
          # apply hover css
          # bit 12
          get_content_param&2048 >0
        when :lightboxable                                # product image
          # bit 13
          get_content_param&4096 >0
        when :model_count_in_row #bit 1,2,3,4             # apply to container
          #how many model this container
          get_content_param&15
        when :datetime_style                              # post time
          # bit 2,3,4
          idx = (get_content_param&14)>>1
          #   000x , 001x,  010x,    011x,    100x
          [:datetime, :date, :time ].fetch( idx, :datetime )

        when :main_image_style                            # section slider, product_image_with_thumbnail
          # bit 2,3,4
          idx = (get_content_param&14)>>1
          # default is medium
          #   000x , 001x,  010x,    011x,    100x
          [:medium, :large, :product, :small, :original ].fetch( idx, :medium )
        when :thumbnail_style
          # bit 5,6,7
          idx = (get_content_param&112)>>4
          [:mini, :large, :medium, :small, :original].fetch( idx, :mini )
        when :zoomable
          # bit 8
          get_content_param&128 > 0
        when :main_image_position                         # section product image
          # bit 9,   10,  product-image
          #   256 + 512 = 768
          (get_content_param&768)>>8
        when :form_enabled                                # container
          # wrap section with form, ex. product quantity, product options, add_to_cart
          # by default there is no form any more, add_to_cart button require form,
          # bit 10
          get_content_param&512 > 0
        when :form_disabled                               #
          # in some case, we want to disable wrapped form of product attributes,
          # ex. show product image only.
          # http://jssor.com/development/define-slides-html-code.html
          # in slider_scrolling, jssor require <div>, not <form>
          # bit 11
          get_content_param&1024 > 0
        when :remote_form_enabled  # support ajax add to cart
          # bit 10&&11
          val = get_content_param
          ( val&1024 > 0 ) && ( val&512 > 0 )
        when :truncate_at                                 # post summary
          # bit 2, 3, 4, 5,  6,  7,  8,  9,
          #     2+ 4+ 8+ 16 +32+ 64+ 128+ 256 = 510
          val = get_content_param&510
          val>0 ? val : default_truncate_at
        when :context
          #图标生成链接时，需要知道对应的 context.
          # bootstrap_glyphicon could link to home/cart...
          #bit 2,3,4,5,6  max is 31
          #000010       000100   000110       001000     001010      001100    001110        010000    010010
          #2:home       4:cart   6:checkout   8:thanks   10:signup   12:login  14:account   16:blog    18:list
          #1            2        3            4          5           6         7            8          9   # keep it same as taxon.page_context
          (get_content_param&62)>>1
        else
          nil
        end
      end

      #:clickable,:main_image_style,:thumbnail_style
      def update_content_param( options )
        options.each_pair{|key, val|
          content_param |= val.to_i
        }
        save!
      end

      # we want to inherit content_param form section, page_layout could override it.
      # ex. section have hover effect, page_layout should have hover effect by default.
      # get content from section, if self.content_param==0.
      def get_content_param
        self.content_param == 0 ? section.content_param : self.content_param
      end

    end

    def has_child?
      return (rgt-lft)>1
    end


    def stylish_with_inherited
      return self.stylish if self.stylish>0
      #在解析模板的每一个page_layout时，都需要调用这个方法，这会发生查询每一个节点的前辈，
      #为了减少数据库查询和便于缓存，这里使用查询这个树，再找前辈的方式

      #inherited = self.ancestors.select{|page_layout| page_layout.stylish >0 }.last
      inherited = self.root.self_and_descendants.select{|page_layout| page_layout.is_ancestor_of?(self) }.select{|page_layout| page_layout.stylish >0 }.last

      return inherited.stylish if inherited.present?
      return 0
    end

    # get applicable resources for self
    def applicable_reources
      self.section.self_and_descendants(:include=>:section_piece).select{|node|
        node.section_piece.resources
      }.select{|resource| resource.present?}
    end


    def partial_html
      pvs = self.param_values.includes(:section_param=>:section_piece_param)
      HtmlPage::PartialHtml.new(nil, self, nil, pvs)
    end

    begin 'modify page layout tree'
      # * usage - copy whole tree
      # * return - root of new copied whole tree
      #def copy_to_new(new_attributes = nil)
      #  raise "only work for root" unless root?
      #  #create new root first, get new root id.
      #  self.class.copy_to_new( self_and_descendants, new_attributes ).first
      #end

      #def copy_to_new(new_attributes = nil)
      #  raise "only work for root" unless root?
      #  #create new root first, get new root id.
      #  duplicated = self.duplicator.duplicate
      #  duplicated.save!
      #  duplicated
      #end

      # it is not using
      # Usage: modify layout, add the section instance as child of current node into the layout,
      # Params: page_layout, instance of model PageLayout
      # return: added page_layout record
      #
      #def add_section(section, attrs={})
      #  # check section.section_piece.is_container?
      #  obj = nil
      #  if section.root? and self.section.section_piece.is_container
      #    whole_tree = self.root.self_and_descendants
      #    section_instance = whole_tree.select{|xnode| xnode.section_id==section.id}.size.succ
      #    attrs[:title]||="#{section.slug}#{section_instance}"
      #    obj = self.dup
      #    obj.section_id, obj.section_instance=section_id, section_instance
      #    obj.assign_attributes( attrs )
      #    obj.save!
      #    obj.move_to_child_of(self)
      #  end
      #  obj
      #end

      # Usage: remove param_values belong to self in every theme while destroy self(page_layout record)
      def remove_section
        remove_param_value()
      end
      #Usage:  add param_value of section into this layout
      def add_param_value(theme)
        # section_id, section_piece_param_id, section_piece_id, section_piece_instance, is_enabled, disabled_ha_ids
        # all section_params belong to section tree.
        # section_tree = self.section.self_and_descendants.includes(:section_params)
        # get default values of this section
        #TODO no need add param_value any more, use default value before user modify it
        page_layout_root_id = self.root.id
        for section_node in self.section.self_and_descendants.includes(:section_params)
          section_params = section_node.section_params
          for sp in section_params
            #use root section_id
            ParamValue.create(:page_layout_root_id=>page_layout_root_id, :page_layout_id=>self.id) do |pv|
              pv.section_param_id = sp.id
              pv.theme_id = theme.id
              pv.pvalue = sp.default_value
              #set default empty {} for now.
            end
          end
        end

      end

      def remove_param_value()
        #ParamValue.delete_all(["page_layout_id=? and theme_id in (?)", self.id, themes.collect{|obj|obj.id }])
        ParamValue.delete_all(["page_layout_id=? ", self.id])
      end

      def demote
        if left_sibling.present?
          move_to_child_of( left_sibling )
        end
      end

      def promote
        unless root?
          move_to_right_of( parent )
        end
      end

      # replace section with another section, this section only for development for now
      # ex. we developed a section with new feature, a page_layout tree want to have this feature, it could replace its original section with new section.
      #     for leaf we could just remove a section, then add new one. Root or some ancestor, replace is better way for developer and user.
      def replace_with( new_section)
        #1. delete all param_values of original section.
        #2. update section_id of current page_layout.
        #3. add new param_values of new sections for each template theme which is using current page_layout
        self.remove_param_value()
        new_section_instance =  self.root.self_and_descendants.select{|xnode| xnode.section_id==new_section.id }.size.succ
        self.section_id, self.section_instance=new_section.id, new_section_instance
        self.save!
        self.themes.each{|theme|
          self.add_param_value(theme)
        }
      end
    end

    begin 'section content, html, css, js'
      def build_content( special_contexts=[] )
        tree = self.self_and_descendants.includes(:section=>[:section_piece, :full_set_nodes])
        # have to Section.all, we do not know how many section_pieces each section contained.
        sections = Section.includes(:section_piece)
        section_hash = sections.inject({}){|h, s| h[s.id] = s; h}
        css = build_css(tree, self, section_hash)
        htmls = build_htmls(tree,  section_hash, special_contexts)
        js = build_js(tree, sections)
        return htmls, css, js
      end

      # Usage: build html, js, css for a layout
      # Params: theme_id,
      #         if passed, build css for that theme, or build css for default theme
      # 返回数组
      def build_htmls(tree = [], section_hash = {}, special_contexts=[])
        if special_contexts.present?
          special_contexts.map{|special_context|
            build_section_html(tree, self, section_hash, special_context)
          }
        else
          [:any_context].map{
            build_section_html(tree, self, section_hash)
          }
        end
      end

      def build_css(tree, node, section_hash, theme_id=0)
        css = node.section.build_css
        css.insert(0, get_section_script(node))
        unless node.leaf?
          children = tree.select{|n| n.parent_id==node.id}
          for child in children
            subcss = build_css(tree, child, section_hash)
            css.concat(subcss)
          end
        end
        css
      end

      def build_js(tree, sections)
        section_ids = tree.collect{|node|node.section_id}
        section_piece_ids = sections.select{|s| section_ids.include?(s.root_id) or section_ids.include?(s.id) }.collect{|s| s.section_piece_id}
        js = ''
        if section_piece_ids.present?
          section_pieces = SectionPiece.find(section_piece_ids)
          js = section_pieces.inject(''){|sum, sp| sum.concat(sp.js); sum}
        end
        return js
      end

      # highlight this page_layout.
      # or get subsection of section tree.
      def css_selector( subsection = nil )
        subsection.blank? ? ".s_#{id}_#{section_id}" : ".s_#{id}_#{subsection.id}"
      end

    end

    #param: some_event could be a global_param_value changed event or a section_event.
    def subscribe_event?( some_event)
      section_events = self.section.subscribed_global_event_array
      section_events.include? some_event.event_name
    end

    #usage: raise this global_param_value_event to whole layout tree or not
    def raise_event?( some_event)
      reserved_section_events = self.section.global_event_array
      reserved_section_events.include? some_event.event_name
    end
    # get all descendants which reserved the :some_event
    def nodes_for_event(some_event)
      @subscribe_event_nodes_hash ||={}
      unless @subscribe_event_nodes_hash.key?  some_event.event_name
        nodes = self.root.self_and_descendants.select{|layout| layout.section.global_event_array.include? some_event.event_name}
        @subscribe_event_nodes_hash[some_event.event_name] = nodes
      end
      @subscribe_event_nodes_hash[some_event.event_name]
    end

    begin 'handle context'
      # a section could have several contexts, means it could appear in serveral kind of pages
      # return array of current contexts
      def current_contexts
        if @current_contexts.blank?
          @current_contexts = ( self.section_context.present? ? self.section_context.split(',').map(&:to_sym) : inherited_contexts )
        end
        @current_contexts
      end

      # * params
      #   * new_context - one value of Contexts or an array of contexts
      def update_section_context( new_context)
        new_context  = [new_context] unless new_context.kind_of?( Array )
        new_context = new_context.map(&:to_sym) # "".to_sym == ContextEnum.either
        raise ArgumentError unless self.class.verify_contexts( new_context, inherited_contexts)
        # test would check section_context,so keep it as string
        self.update_attribute(:section_context,new_context.join(','))
        if new_context.first != ContextEnum.either
          #update descendant's context,
          self.descendants.where(["section_context!=?",ContextEnum.either]).each{|node|
            #only reset context if desendant's context is invalid for new_context.
            unless self.class.verify_contexts( node.current_contexts, new_context )
              node.update_attribute(:section_context, ContextEnum.either)
            end
          }
          #TODO correct descendants's data_source
          self.update_data_source( DataSourceEmpty )
        end
      end

      # called in current_page_tag
      def valid_context?(some_context)
        self.class.verify_contexts some_context.to_sym, current_contexts
      end
      def context_cart?
        current_contexts.include? ContextEnum.cart
      end
      def context_account?
        current_contexts.include? ContextEnum.account
      end
      def context_list?
        current_contexts.include? ContextEnum.list
      end
      def context_detail?
        current_contexts.include? ContextEnum.detail
      end
      def context_either?
        current_contexts.include? ContextEnum.either
      end

    end

    begin 'handle data source'
      # * data source has two parts, data and filter, separated by '|'
      # * current data_source could be nil
      def current_data_source
        self.data_source.present? ? self.data_source.to_sym : DataSourceEmpty
      end

      def inherited_data_source
        return DataSourceEmpty if self.root?
        ancestor_data_source = self.ancestors.collect{|page_layout| page_layout.data_source }.last
        ancestor_data_source.present? ? ancestor_data_source.to_sym : DataSourceEmpty
      end

      # verify new_data_source
      def update_data_source( new_data_source )
        # update self data_source
        original_data_source = self.data_source
        self.data_source = new_data_source
        if new_data_source.blank? || self.is_valid_data_source?
          self.update_attribute(:data_source,new_data_source )
          #verify descendants, fix them.
          verify_required_descendants = self.descendants.where('data_source!=?', DataSourceEmpty)
          for node in verify_required_descendants
            unless node.is_valid_data_source?
              node.update_data_source(DataSourceEmpty)
            end
          end
        else
          self.data_source = original_data_source
        end
        self
      end

      # * is self.data_source valid to ancestors
      def is_valid_data_source?
        is_valid = false
        if self.current_data_source != DataSourceEmpty
          if self.inherited_data_source == DataSourceEmpty # top level data source
            section_contexts = self.current_contexts
            if  section_contexts.length == 1
              available_data_sources =  ContextDataSourceMap[section_contexts.first]
              if available_data_sources.present?
                is_valid = ( available_data_sources.include? self.current_data_source )
              end
            else
              #TODO validate data source for more than on section contexts
              is_valid = true
            end
          else #sub level data source
            #Rails.logger.debug "self.inherited_data_source=#{self.inherited_data_source}"
            is_valid = ( DataSourceChainMap[self.inherited_data_source].include? self.current_data_source)
          end
        else
          is_valid = true
        end
#Rails.logger.debug "is_valid = #{is_valid}"
        is_valid
      end

      # get available data sources for self
      def available_data_sources
        data_sources = []
        if self.current_contexts.size == 1
          the_context = self.current_contexts.first
          if  the_context != ContextEnum.either
            the_data_source = self.inherited_data_source
            if the_data_source == DataSourceEmpty # top level data source
              data_sources =  ContextDataSourceMap[the_context]
            else
              data_sources = DataSourceChainMap[the_data_source]
            end
          end
        end
        data_sources
      end

      def wrapped_data_source_param
        params = {}
        if data_source_param.present?

          splited_params = data_source_param.split(',')
          if current_data_source == DataSourceEnum.gpvs || current_data_source == DataSourceEnum.blog || current_data_source == DataSourceEnum.related_products

            params[:per_page]= splited_params[0].to_i
            params[:pagination_enable] = ( splited_params[1].blank? ||  splited_params[1] == '1')
            params[:pagination_style] = ( splited_params[2] )

          elsif current_data_source == DataSourceEnum.taxonomy
            params[:depth] = splited_params[0].to_i
          else
            # section :page_attribute, :product_attribute, :post_attribute
            params[:attribute_name] = splited_params[0]
          end
        end
        params
      end

      def get_data_source_param_by_key( key )
        wrapped_data_source_param[key]
      end

    end

    # self.css_class + self.usage
    def get_css_class
      css = String.new()
      css << css_class if css_class.present?
      #css << css_class_for_js if css_class_for_js.present?
      css << " "+ self.section.usage_css_name
      css
    end

    private
    # a page_layout build itself.
    def build_section_html(tree, node, section_hash, special_context = nil)
      #
      return '' if special_context.present? && !node.valid_context?(special_context)
      return '' unless node.is_enabled?
      subpieces = ""
      unless node.leaf?
        subnodes = tree.select{|n| n.parent_id==node.id}
        for child in subnodes
          next unless child.is_enabled?
          subpiece = build_section_html(tree, child, section_hash, special_context)
          subpieces.concat(subpiece)
        end
      end
      piece = node.section.build_html
      # replace ~~selectors~~ with ex. 's_112_2 c_111'
      unless node.root?
        offline_css = "s_#{node.id}_#{node.section_id} c_#{node.parent_id} #{node.get_css_class}"
        if node.has_extra_selector?
          piece.sub!('~~selector~~', "#{offline_css} <%=@template.get_css_classes %>")
        else
          piece.sub!('~~selector~~', offline_css)
        end
        #if node.content_css_class.present?
        #  piece.sub!(/\bcontent_css_class_placeholder/, node.content_css_class)
        #end
      end
      # if node.root?
      #   piece.insert(0,init_vars)
      # end
      # select current page_layout at end of subpieces,  pagination required, data_souce_param is on current page_layout
      subpieces << get_section_script(node) if subpieces.present?

      #piece may contain several ~~content~~, the deepest one is first.
      if(pos = (piece=~/~~content~~/))
        if node.data_source.present? #node.data_source.singularize
          case node.current_data_source
            # var_collection has to vary in name, may be nested.
            # data_source, data_item is for column index computing.
          when DataSourceEnum.gpvs, DataSourceEnum.this_product, DataSourceEnum.gpvs_theme
              # for this_product, we have to wrapped with form, or option_value radio would not work.
              form_enabled = node.get_content_param_by_key( :form_enabled )
              remote_form_enabled = node.get_content_param_by_key( :remote_form_enabled )
              if remote_form_enabled
                form_start = '<%= form_for :order, url: populate_orders_path, remote: true do |f| %>'
                form_end =   '<% end %>'
              elsif form_enabled
                form_start = '<%= form_for :order, url: populate_orders_path do |f| %>'
                form_end =   '<% end %>'
              else
                form_start = form_end =nil
              end
              # once data_source retrieved, we should use context :site1_themes to support product_property.property.presentation
              subpieces = <<-EOS1
              <% @template.running_data_source= @template.products( (defined?(page) ? page : @current_page) ) %>
                <% @template.running_data_source.each(){|product| @template.running_data_item = product %>
                    #{form_start}
                    #{subpieces}
                    #{form_end}
                <% } %>
                #{get_pagination(node)}
              <% @template.running_data_source = nil %>
              EOS1
              #set var_collection  to nil, or render pagination more times
          when DataSourceEnum.related_products
              subpieces = <<-EOS1
              <% @template.running_data_source= @template.related_products(  ) %>
                <% @template.running_data_source.each(){|product| @template.running_data_item = product %>
                    #{subpieces}
                <% } %>
                #{get_pagination(node)}
              <% @template.running_data_source = nil %>
              EOS1

          when DataSourceEnum.blog, DataSourceEnum.post
              subpieces = <<-EOS1
              <% @template.running_data_source= @template.posts( (defined?(page) ? page : @current_page) ) %>
              <% @template.running_data_source.each{|post| @template.running_data_item = post %>
                  #{subpieces}
              <% } %>
              #{get_pagination(node)}
              <% @template.running_data_source = nil %>
              EOS1
            #when DataSourceEnum.related_posts
            #  subpieces = <<-EOS1
            #  <% @template.running_data_source= @template.related_posts( (defined?(page) ? page : @current_page) ) %>
            #  <% @template.running_data_source.each{|post| @template.running_data_item = post %>
            #      #{subpieces}
            #  <% } %>
            #  <% @template.running_data_source = nil %>
            #  EOS1
          when DataSourceEnum.taxonomy
              #assigned menu could be root or node
              subpieces = <<-EOS3
              <% if @template.menu.present? %>
                <% if @template.menu.root? %>
                  <% @template.running_data_source= @template.menu.children %>
                  <% @template.running_data_source.each{|page| @template.running_data_item = page %> #{subpieces} <%}%>
                  <% @template.running_data_source = nil %>
                <% else %>
                  <% @template.running_data_source= @template.menu %>
                  <% @template.running_data_source.tap{|page| @template.running_data_item = page %> #{subpieces} <%}%>
                  <% @template.running_data_source = nil %>
                <% end %>
              <% end %>
              EOS3
          when DataSourceEnum.taxon
              #assigned node, could be root
              subpieces = <<-EOS6
              <% if @template.menu.present? %>
                  <% @template.running_data_source= @template.menu %>
                  <% @template.running_data_source.tap{|page| @template.running_data_item = page %> #{subpieces} <%}%>
                  <% @template.running_data_source = nil %>
              <% end %>
              EOS6
          when DataSourceEnum.related_taxa
              #assigned node, could be root
              subpieces = <<-EOS7
                  <% @template.running_data_source= @template.related_taxa%>
                  <% @template.running_data_source.each{|page| @template.running_data_item = page %> #{subpieces} <%}%>
                  <% @template.running_data_source = nil %>
              EOS7
          end
        end
        # we recovery template.select after ~~content~~
        piece.insert(pos,subpieces)
      end

      if node.section_context.present?
        # should set current page_layout before do valid_context.
        piece = <<-EOS2
          <% if @current_page.valid_context? %>
          #{piece}
          <% end %>
        EOS2
      end

      piece = "#{get_section_script(node)}  #{piece} "

      # remove ~~content~~ however, node could be a container.
      # in section.build_html, ~~content~~ have not removed.
      # there could be more than one ~~content~~, use gsub!
      piece.gsub!(/~~content~~/,'')
      piece
    end

    # section_context could be more than one.
    def inherited_contexts
      #ancestors order by lft
      if @inherited_contexts.blank?
        ancestor_context = self.ancestors.where('section_context!=?','').collect{|page_layout| page_layout.section_context }.last
        @inherited_contexts = ( ancestor_context.present? ? ancestor_context.split(',').map(&:to_sym) : [ContextEnum.either] )
      end
      @inherited_contexts
    end

    def inherited_section_context
      #ancestors order by lft
      ancestor_context = self.ancestors.where('section_context!=?','').collect{|page_layout| page_layout.section_context }.last
      ancestor_context.present? ? ancestor_context.to_sym : ContextEnum.either
    end

    def get_section_script(node)
      # we have to call @template.select(g_page_layout_id);
      # valid_context require current page_layout, we should not move valid_context? into section.
      "<% @template.select(#{node.id}, 0) %>"
    end

    # show pagination when section is configured, data_source_param > 0
    # ex. in home page, we have product list, we do not want to show pagination even products.count > Spree::Config[products_per_page]
    def get_pagination( node )
      params = node.wrapped_data_source_param
      pagination_params = { pagination_style: params[:pagination_style],
        pagination_plid: node.id
      }
      # section is configured and datasource have pages
      # notice: current piece is data iterator parent at present.  ex. product_list(current_piece)->one_product
      #if @template.current_piece.per_page>0 && @template.current_piece.pagination_enable?
      if params[:pagination_enable] && params[:per_page] >0
        if params[:pagination_style] == PaginationStyle.pn_links
          "<%= paginate( @template.running_data_source, theme: 'pn', params: #{pagination_params.to_s} )  if @template.running_data_source.try( :has_pages? ) %> "
        else
          "<%= paginate( @template.running_data_source, params: #{pagination_params.to_s} )  if @template.running_data_source.try( :has_pages? ) %> "
        end
      end
    end

    # Do not support add_layout_tree now. Page layout should be full html, Keep it simple.
    # since we add feature 'section_context' and 'data_source', should not allow user use this method, it may cause section_context conflict.
    # user copy prebuild layout tree to another layout tree as child.
    # copy it self and decendants to new parent. this only for root layout.
    # include theme param values. add theme param values to all themes which available to the new parent.
    #def add_layout_tree(copy_layout_id)
    #  copy_layout = self.class.find(copy_layout_id)
    #  raise "only for root layout" unless copy_layout.root?
    #  copy_layout.copy_to_new_parent(self)
    #end

    #  cached_whole_tree, it is whole tree of new parent, to compute new added section instance.
    #  added_section_ids, new added section ids, but not in cache.
    #  root_layout.copy_to()
    #def copy_to_new_parent(new_parent, cached_whole_tree = nil, added_section_ids=[])
    #  cached_whole_tree||= new_parent.root.self_and_descendants
    #  new_section_instance =  ( cached_whole_tree.select{|xnode| xnode.section_id==self.section_id}.size +
    #    added_section_ids.select{|xid| xid==self.section_id}.size ).succ
    #  clone_node = self.dup # do not call clone, or modify itself
    #  clone_node.parent_id = new_parent.id
    #  clone_node.root_id = new_parent.root_id
    #  clone_node.section_instance = new_section_instance
    #  clone_node.copy_from_root_id =  self.root_id
    #  clone_node.save!
    #  added_section_ids << clone_node.section_id
    #  # it should only have one theme.
    #  copy_theme = self.root.themes.first
    #  table_name = ParamValue.table_name
    #  table_column_names = ParamValue.column_names
    #  table_column_names.delete('id')
    #  # copy param values to all available themes
    #  for theme in clone_node.root.themes
    #    table_column_values  = table_column_names.dup
    #    table_column_values[table_column_values.index('page_layout_root_id')] = clone_node.root_id
    #    table_column_values[table_column_values.index('page_layout_id')] = clone_node.id
    #    table_column_values[table_column_values.index('theme_id')] = theme.id
    #    sql = %Q!INSERT INTO #{table_name}(#{table_column_names.join(',')}) SELECT #{table_column_values.join(',')} FROM #{table_name} WHERE ((page_layout_root_id=#{self.root_id} and page_layout_id =#{self.id}) and theme_id =#{copy_theme.id} )!
    #    self.class.connection.execute(sql)
    #  end
    #  for node in self.children
    #    node.copy_to_new_parent(clone_node, cached_whole_tree, added_section_ids)
    #  end
    #end

    # empty data_source_param when data_source is empty
    def set_default_values
      #page_attribute no need data_source.

      #if self.data_source.blank? && self.data_source_param.present?
      #  self.data_source_param = ''
      #end
      self.content_param = 0 if content_param.blank?
    end

  end

end
