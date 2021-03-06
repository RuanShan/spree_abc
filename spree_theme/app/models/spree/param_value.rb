module Spree
  class ParamValue < ActiveRecord::Base
    EventEnum={:psv_changed=>'psv_changed',:pv_changed=>'pv_changed',:psu_changed=>'psu_changed',:unset_changed=>'unset_changed'}
    belongs_to :section_param
    belongs_to :page_layout, :foreign_key=>"page_layout_id"
    belongs_to :page_layout_root, :foreign_key=>"page_layout_root_id", class_name: 'Spree::PageLayout'
    belongs_to :template_theme, :foreign_key=>"theme_id"

    serialize :pvalue, Hash
    #serialize :pvalue1, Hash
    #serialize :pvalue2, Hash
    #serialize :pvalue3, Hash

    before_update :collect_events # skip create
    after_update :trigger_events

    scope :within_section, ->( param_value ){
        where(" theme_id=? and page_layout_id=? ", param_value.theme_id, param_value.page_layout_id)
      }
    scope :within_editor, ->( editor ){
        includes(:section_param=>:section_piece_param).where("#{SectionPieceParam.table_name}.editor_id"=>editor.id)
      }

    #attr_accessible :page_layout_root_id, :page_layout_id,:section_id
    attr_accessor :updated_html_attribute_values, :original_html_attribute_values, :page_events

    # is it editable by editor, ex. pagination param_value should not appear if page_layout have no data source
    def editable?
      section_param.section_piece_param.editable? page_layout.current_data_source
    end

    # usage: return all html_attribute_values this param value contains.
    #   return a hash, values are instance of HtmlAttributeValue, keys are html_attribute_id and html_attribute.slug.
    #   key is section_param.section_piece_param.class_name+html_attribute.slug. ex."block_width"
    #   unique_key = hav.computed? ?  "computed_#{class_name}_#{hav.html_attribute.slug}" : "#{class_name}_#{hav.html_attribute.slug}"
    def html_attribute_values_hash
      ha_array = HtmlAttribute.find_by_ids(self.html_attribute_ids)
      hav_hash = ha_array.inject({}){|h, ha| hav = HtmlAttributeValue.parse_from(self,ha);
        h[ha.id]=hav;
        unique_key = "#{hav.param_value.section_param.section_piece_param.class_name}_#{hav.html_attribute.css_name}"
        h[unique_key]=hav; h
      }
      hav_hash
    end


    def html_attribute_ids()
      if @html_attribute_ids.nil?
        section_piece_param = self.section_param.section_piece_param
        @html_attribute_ids = section_piece_param.html_attribute_ids.split(',').collect{|i|i.to_i}
      end
      @html_attribute_ids
    end

    def html_attribute_value(html_attribute)
      return HtmlAttributeValue.parse_from(self,html_attribute)
    end

    #belongs_to_html_attribute_ids could be Array or an html_attribute_id
    def attribute_values(belongs_to_html_attribute_ids)
      belongs_to_html_attribute_ids ||= self.html_attribute_ids
      belongs_to_html_attribute_ids = belongs_to_html_attribute_ids.map(&:to_s)
      return self.pvalue.slice(*belongs_to_html_attribute_ids).values if belongs_to_html_attribute_ids.kind_of?(Array)
      self.pvalue.slice(belongs_to_html_attribute_ids).values
    end

    def pvalue_for_haid(html_attribute_id)
      self.pvalue[html_attribute_id.to_s]
    end
    def set_pvalue_for_haid(html_attribute_id, value_for_ha)
      self.pvalue[html_attribute_id.to_s]  = value_for_ha
    end
    def set_unset_for_haid(html_attribute_id, unset_for_ha)
      self.pvalue["#{html_attribute_id}unset"] = unset_for_ha
    end

    def unset?(html_attribute_id)
      ( self.html_attribute_extra(html_attribute_id, 'unset')== HtmlAttribute::BOOL_FALSE) ? false : true
    end

    # use in page_generator
    def hidden?(html_attribute_id)
      # all computed are hidden
      ( self.html_attribute_extra(html_attribute_id,'hidden')== HtmlAttribute::BOOL_TRUE or computed?) ?  true : false
    end

    def computed?(html_attribute_id)
      ( self.html_attribute_extra(html_attribute_id,'computed')== HtmlAttribute::BOOL_TRUE) ?  true : false
    end

    def html_attribute_extra(html_attribute_id, attr_name, attr_val = nil )
      if attr_val.nil?
        self.pvalue["#{html_attribute_id}#{attr_name}"]
      else
        self.pvalue["#{html_attribute_id}#{attr_name}"] = attr_val
      end
    end

    #def disabled_html_attribute_ids
    #  if @disabled_html_attribute_ids.nil?
    #    @disabled_html_attribute_ids = self.disabled_ha_ids.split(',').collect{|i|i.to_i}
    #  end
    #  @disabled_html_attribute_ids
    #end

    # in case, there is only one html_attribute_id in current param_value
    # use this to fetch param value directly.
    def first_pvalue
      pvalue_for_haid( html_attribute_ids.first )
    end

    def partial_html
      pvs = self.class.within_section(self).includes(:section_param=>:section_piece_param)
      HtmlPage::PartialHtml.new(nil, self.page_layout, nil, pvs)
    end

    begin 'update param value'
      # * usage - update attribute:pvalue
      # * params
      #   * html_attribute_value_params - it is hash like {"psvalue0"=>"l1", "pvalue0"=>"810", "unit0"=>"px"}
      #      or {"psvalue0"=>"l1", "pvalue0"=>"0", "unit0"=>"px", "psvalue1"=>"l1", "pvalue1"=>"0", "unit1"=>"px", "psvalue2"=>"l1", "pvalue2"=>"0", "unit2"=>"px", "psvalue3"=>"l1", "pvalue3"=>"0", "unit3"=>"px", "unset"=>"1"}
      #   * some_event - one of EventEnum
      def update_html_attribute_value(html_attribute, html_attribute_value_params, some_event )
        #FIXME confirm next line.
        # it maybe called more times by conditions, we should keep updated_html_attribute_values
        self.page_events ||=[]
        self.updated_html_attribute_values ||= []
        self.original_html_attribute_values ||= []
        original_html_attribute_value = HtmlAttributeValue.parse_from(self,html_attribute)
        new_html_attribute_value = HtmlAttributeValue.parse_from(self, html_attribute, html_attribute_value_params)
        is_updated= false
        # Rails.logger.debug "original_html_attribute_value=#{original_html_attribute_value.properties.inspect},new_html_attribute_value=#{new_html_attribute_value.properties.inspect}"
        unless original_html_attribute_value.equal_to?(new_html_attribute_value)
          # changed by user actions, some_event = [pv_changed|psv_changed|psu_changed|unset_changed]
          if EventEnum.key? some_event
            if some_event==EventEnum[:unset_changed]
              if new_html_attribute_value.unset?
                self.html_attribute_extra(html_attribute.id, 'unset', new_html_attribute_value.unset)
              else # user modify unset, we should give a default value.
                self.html_attribute_extra(html_attribute.id, 'unset', new_html_attribute_value.unset)
                self.set_pvalue_for_haid(html_attribute.id, new_html_attribute_value.build_pvalue(default=true))
              end
            else
              self.set_pvalue_for_haid(html_attribute.id, new_html_attribute_value.build_pvalue)
            end
          else
            # no event here, we would program to change html_attribute_value, like section.width = 100
            if new_html_attribute_value.hidden != original_html_attribute_value.hidden
              self.html_attribute_extra(html_attribute.id, 'hidden', new_html_attribute_value.hidden)
            end
            if new_html_attribute_value.unset != original_html_attribute_value.unset
              self.html_attribute_extra(html_attribute.id, 'unset', new_html_attribute_value.unset)
            end
            if new_html_attribute_value.computed != original_html_attribute_value.computed
              self.html_attribute_extra(html_attribute.id, 'computed', new_html_attribute_value.computed)
            end
            self.set_pvalue_for_haid(html_attribute.id, new_html_attribute_value.build_pvalue)
          end
          self.updated_html_attribute_values << new_html_attribute_value
          self.original_html_attribute_values << original_html_attribute_value
          self.page_events << some_event
          self.save!
          is_updated = true
        end
        [is_updated, new_html_attribute_value, original_html_attribute_value]
      end

      #Usage:  user modify param_value, trigger event, event in EventEnum
      # flow chart is:
      #            client side               server side
      #  user modify param_value ->       raise_event -> if(change_event) modify pvalue(not save) ->
      #                                   accumulate modification event, include global_param_value_event and section_event ->
      #                                   after pv.save -> call trigger_event
      #
      def collect_events()
        @param_value_events=[]
        @global_param_value_events=[]
        if self.page_events.present?
          last_position =  self.page_events.size - 1
          # tell current section, this is new html attribute value.
          pve = PageEvent::ParamValueEvent.new(self.page_events.first, self, self.original_html_attribute_values.first, self.updated_html_attribute_values.first )
          @param_value_events<<pve
          # Disable GlobalParamValueEvent, it is not using and well tested.
          #se = PageEvent::GlobalParamValueEvent.new(self.page_events.first, self, self.original_html_attribute_values.first, self.updated_html_attribute_values.first )
          #if self.page_layout.subscribe_event?(se)
          #  @global_param_value_events << se
          #end
        end
      end

      # Usage: it is called after save, to trigger accumulated events.
      # we also collect all updated_html_attribute_values which caused by GlobalParamValueEvent or ParamValueEvent events.
      def trigger_events
        extra_html_attribute_values = []
        #@param_value_events may be nil, ex. load seed.
        if @param_value_events.present?
          param_value_events = @param_value_events
          @param_value_events = nil # in case update self.pvalue, trigger again.
          param_value_events.each{|pve|
            extra_html_attribute_values.concat( pve.notify )
          }
        end
        if @global_param_value_events.present?
          section_events = @global_param_value_events
          @global_param_value_events = nil # in case update self.pvalue, trigger again.
          section_events.each{|pve|
            extra_html_attribute_values.concat(pve.notify)
          }
        end
        extra_html_attribute_values.each{|hav| hav.update}
        #in section_param.add_default_value, it update param_value, it trigger this method, updated_html_attribute_values is nil at this time
        self.updated_html_attribute_values||=[]
        self.updated_html_attribute_values.concat(extra_html_attribute_values )
      end
    end

  end

end
