//= require jquery
//= require jquery.validate/localization/messages_zh-CN.js
//= require jquery.simplemodal.js

$(document).ready(function() {
  // template theme selection for designer shop
  $( "#embeded_content_wrapper" ).hover(
    function() { $(this).show(); $( "#embeded_content_wrapper_icon" ).hide();},
    function() { $(this).hide(); $( "#embeded_content_wrapper_icon" ).show();}
  );
  $( "#embeded_content_wrapper_icon" ).hover(
    function() { $( "#embeded_content_wrapper" ).show(); }
  );
  
});
$(document).ready(function() {
  // initialize sections    
    //$($("input.fixed_container").val()).floatBar({
    //    bodyWidth:980, vertical:"top",  moveOnOff:false, focusOnOff:false
    //  });
    $("input.hover_effect_container").each(function(index, element){
      var children = $(element).siblings('div');
      if( children.length == 2){
        var child1 = $(children[0]); var child2 = $(children[1]);   
        child2.on('mouseenter',function(){ child1.show();child2.hide(); })  
        child1.on('mouseout', function(){child2.show();child1.hide();})  
      }
    })      
});

// copy from project https://github.com/citrus/spree_variant_options
// params:
//   view_style: 'slide',null
//   options:  { option_id=>{ option_value_id=>{ variant_id=>variant } } }
//   allow_select_outofstock: By setting allow_select_outofstock to true, when an user selects variant options it will automatically update any form's input variant_id with an data-form-type="variant" attribute.
//   default_instock: (default: false) If this is option is set to true, it will automatically preselect in-stock variant options.
function VariantOptions(params) {
    var view_style = params['view_style']
    var options = params['options'];
    var container_selector = params['container_selector']
    var allow_backorders = !params['track_inventory_levels'] ||  params['allow_backorders'];
    var allow_select_outofstock = params['allow_select_outofstock'];
    var default_instock = params['default_instock'];

    var option_types, option_values_container, index = 0;
    // option_types: all option_types included option_values
    // option_values_container: a container for  option_values of an option_type
    var available_variant_ids = []; // base on selected option value, there are some available variant ids 
    var buttons;


    function init() {
        option_types = $(container_selector+" .variant-option");
        disable(option_types.find('a.option-value').addClass('locked'));
        update();
        enable(option_values_container.find('a.option-value'));
        toggle();
        option_types.find('a.option-value').click(handle_click);

        if (default_instock) {
            option_types.each(function(){
                $(this).find("ul.option_values li a.in-stock:first").click();
            });
        }
    }
    
    // set current option type
    function update(i) {
        index = isNaN(i) ? index : i;
        option_values_container = $(option_types.get(index));
        buttons = option_values_container.find('a.option-value');
    }

    function disable(btns) {
        return btns.removeClass('selected');
    }
    // enable option values of current option type
    function enable(btns) {
        var bt = btns.not('.unavailable').removeClass('locked')
        if (!allow_select_outofstock && !allow_backorders){
            bt = bt.filter('.in-stock')
        }            
        return bt.filter('.auto-click').removeClass('auto-click').click();
    }

    function advance() {
        index++
        update();
        inventory(buttons.removeClass('locked'));
        enable(buttons);
    }

    // after use click a option value, we should reset next all option_values
    function clear(i) {
        update(i);
        enable(buttons.removeClass('selected'));
        toggle();
        option_values_container.nextAll().each(function(index, element) {
            disable($(element).find('a.option-value').show().removeClass('in-stock out-of-stock').addClass('locked'));
        });
        hide_all_variant_images();
    }

    function handle_click(evt) {
        evt.preventDefault();
        var target_variant = null;
        available_variant_ids = [];
        var a = $(this);
        //return if has class unavailable locked
        if( a.hasClass("unavailable") || a.hasClass("locked")){
            return
        }
        //if (!allow_select_outofstock && !allow_backorders){
        //    bt = bt.filter('.in-stock')
        //}            
        
        if (a.filter('.selected').length>0){
            // unclick selected, 
            clear(option_types.index(a.parents('.variant-option:first')));
        }else{
            if (!option_values_container.has(a).length) {
                clear(option_types.index(a.parents('.variant-option:first')));
            }
            disable(buttons);
            var a = enable(a.addClass('selected'));
            advance();
            if (target_variant=find_variant()) {
                toggle(target_variant);
            }            
        }        
    }


    function show_variant_images(variant_id) {
        $('li.vtmb').hide();
        $('li.tmb-' + variant_id).show();
        var currentThumb = $('#' + $("#main-image").data('selectedThumbId'));
        // if currently selected thumb does not belong to current variant, nor to common images,
        // hide it and select the first available thumb instead.
        if(!currentThumb.hasClass('tmb-' + variant_id)) {
            //var thumb = $($('ul.thumbnails li:visible').eq(0));
            var thumb = $($("ul.thumbnails li.tmb-" + variant_id + ":first").eq(0));
            if (thumb.length == 0) {
                thumb = $($('ul.thumbnails li:visible').eq(0));
            }
            var newImg = thumb.find('a').attr('href');
            $('ul.thumbnails li').removeClass('selected');
            thumb.addClass('selected');
            $('#main-image img').attr('src', newImg);
            $("#main-image").data('selectedThumb', newImg);
            $("#main-image").data('selectedThumbId', thumb.attr('id'));
        }
    }

    function show_all_variant_images() {
        $('li.vtmb').show();
    }
    function hide_all_variant_images() {
        $('li.vtmb').hide();
    }
    
    function inventory(btns) {
      // for each option_value there is collection of available variants
      // given option_values, Intersection of those collections is final available variants   
        var variant_ids, variants, count = 0, selected = {};
        var sels = $.map(option_types.find('a.selected'), function(i) { return i.rel });
        
        variants = get_variant_objects(sels);
        available_variant_ids = $.map(variants, function(i) { return i.id });
        btns.removeClass('in-stock out-of-stock unavailable').each(function(i, element) {
            variants = get_variant_objects([].concat( sels, element.rel));
            variant_ids = $.map(variants, function(i) { return i.id });
            if (variant_ids.length == 0) {
                disable($(element).addClass('unavailable locked'));
            } else if (variant_ids.length == 1) {
                var _var = variants.pop();
                $(element).addClass((allow_backorders || _var.count) ? available_variant_ids.length == 1 ? 'in-stock auto-click' : 'in-stock' : 'out-of-stock');
            } else if (allow_backorders) {
                $(element).addClass('in-stock');
            } else {
                $.each(variants, function(variant) { count += variant.count });
                $(element).addClass(count ? 'in-stock' : 'out-of-stock');
            }
        });
    }

    //==========================================================================================
    // method for slide style
    //------------------------------------------------------------------------------------------
    function init_for_slide_style() {
        option_types = $(container_selector+" .variant-option");
        option_types.find('a.option-value').click( handle_click_for_slide_style );        
        $(container_selector+' button.next').click( next_step_click );
        $(container_selector+' button.back').click( back_step_click );
        
        initialize_option_view();
    }

    function initialize_option_view (i) {
        index = isNaN(i) ? index : i;
        option_types.hide();
        update_model();
        // hide button back if index =0
        if (index==0){
          $(container_selector+' button.back').attr('disabled', true);    
        }else{
          $(container_selector+' button.back').attr('disabled', false);                
        }
        if ((index+1) == option_types.length){
            $(container_selector+' button.next').attr('disabled', true);                
        }else{
            $(container_selector+' button.next').attr('disabled', false);                
        }
        
        // select one, or no option image show.
        if( option_values_container.find("a.option-value.selected").length == 0)  {
          option_values_container.find("a.option-value:first").click();
        }
        option_values_container.show()     
    }
    // update
    // update data, option_values_container,buttons
    function update_model() {
        option_values_container = $(option_types.get(index));
        buttons = option_values_container.find('a.option-value');
    }
    
    // update price?    
    function update_view() {
        //show 
        var option_type_id_and_option_value_id =  buttons.filter('.selected').attr('rel').split('-');
        option_values_container.find(' .olge').hide();
        option_values_container.find(' .lge-'+option_type_id_and_option_value_id[1]).show();
    }
    
    function next_step_click() {
        index++;
        initialize_option_view();
    }
    
    function back_step_click() {
        index--;
        initialize_option_view();
    }
        
    function handle_click_for_slide_style(evt) {
        evt.preventDefault();
        var a = $(this);
        var target_variant= null;
        //return if has class unavailable locked
        if( a.hasClass("unavailable") || a.hasClass("locked")|| a.hasClass("selected")){
            return
        }          
        buttons.not(a).removeClass('selected');
        a.addClass('selected');
        
        update_view();
        
        target_variant=find_variant()
        toggle(target_variant);
                            
    }
    //                                end slide style
    //==========================================================================================
    
    //==========================================================================================
    // common method for option value
    //------------------------------------------------------------------------------------------
    
    function index_of_array(array, obj) {
        for(var i = 0; i < array.length; i++){
            if(array[i] == obj) {
                return i;
            }
        }
        return -1;
    }
       
    function to_f(string) {
        return parseFloat(string.replace(/[^\d\.]/g, ''));
    }

    function find_variant() {
        var form_container = $(container_selector).parents('form:first')
        var rels = $.map(option_types.find('a.selected'), function(i) { return i.rel });

        var variants = get_variant_objects(rels);
        if (rels.length == option_types.length) {
            return variants.pop();
        } else {
            var prices = [];
            $.each(variants, function(i, variant) { prices.push(variant.price) });
            prices = $.unique(prices).sort(function(a, b) {
                return to_f(a) < to_f(b) ? -1 : 1;
            });
            if (prices.length == 1) {
                form_container.find('.price').html('<span class="price assumed">' + prices[0] + '</span>');
            } else {
                form_container.find('.price').html('<span class="price from">' + prices[0] + '</span> - <span class="price to">' + prices[prices.length - 1] + '</span>');
            }
            return false;
        }
    }
    
    // get variants by selected option_vlaues
    function get_variant_objects(rels) {
      var variant_objects = []
        var i, ids, obj, variants = {};
        if (typeof(rels) == 'string') { rels = [rels]; }
        var otid, ovid, opt, opv;
        i = rels.length;
        try {
            for(var i=0; i<rels.length; i++){              
                ids = rels[i].split('-');
                otid = ids[0];
                ovid = ids[1];
                opt = options[otid];
                if (opt) {
                    opv = opt[ovid];
                    if (opv) {
                      if( i == 0){//
                        variant_objects = $.map(opv, function(variant, variant_id) { return variant });
                      }else{
                        variant_objects = variant_objects.filter(function(variant) {  return opv[variant.id.toString()] } );                        
                      }                       
                    }
                }
            }
        } catch(error) {
            //console.log(error);
        }
        return variant_objects;
    }

    function toggle( target_variant) {
        var form_container = $(container_selector).parents('form:first')
        if (target_variant) {
            form_container.find('input.variant_id').val(target_variant.id);
            form_container.find('.price').removeClass('unselected').text(target_variant.price);
            if (target_variant.count > 0 || allow_backorders)
                form_container.find('button[type=submit]').attr('disabled', false).fadeTo(100, 1);
            try {
                show_variant_images(target_variant.id);
            } catch(error) {
                // depends on modified version of product.js
            }
        } else {
            form_container.find('input.variant_id').val('');
            form_container.find('button[type=submit]').attr('disabled', true).fadeTo(0, 0.5);
            var price = form_container.find('.price').addClass('unselected')
            // Replace product price by "(select)" only when there are at least 1 variant not out-of-stock
            var variants = $("div.variant-option.index-0")
            if (variants.find("a.option-value.out-of-stock").length != variants.find("a.option-value").length)
                price.text('(select)');
        }
    }

    //                               end common methods 
    //==========================================================================================
    
    // it is unused for now.
    function option_value_click_handler(){
        evt.preventDefault();
        available_variant_ids = [];
        var a = $(this);
        //return if has class unavailable locked selected
        if( a.hasClass("unavailable") || a.hasClass("locked") ||  a.hasClass("selected")){
            return
        }        
        // select option type
        // select current clicked option value
        // correct next all selected option value          
    }
    
    if( view_style == 'slide' ){
      $(document).ready(init_for_slide_style);      
    }else{
      $(document).ready(init);
    }
};
