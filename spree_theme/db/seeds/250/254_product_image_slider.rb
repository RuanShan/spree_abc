product_image_slider = Spree::Section.create_section(section_piece_hash['container'], {:title=>"slider for product images"},
  {'block'=>{'disabled_ha_ids'=>'111','21unset'=>'0','21'=>'width:600px','15unset'=>'0','15'=>'height:200px'},
   'inner'=>{'15unset'=>'0','15'=>'height:200px','15hidden'=>bool_true,'21hidden'=>bool_true}})

product_image_slider.add_section_piece(section_piece_hash['slider-core']).add_section_piece(section_piece_hash['slider-data-product-images'])


taxon_slider = Spree::Section.create_section(section_piece_hash['container'], {:title=>"Slider for taxonomy images "},
  {'block'=>{'disabled_ha_ids'=>'111','21unset'=>'0','21'=>'width:600px','15unset'=>'0','15'=>'height:200px'},
   'inner'=>{'15unset'=>'0','15'=>'height:200px','15hidden'=>bool_true,'21hidden'=>bool_true}})

taxon_slider.add_section_piece(section_piece_hash['slider-core']).add_section_piece(section_piece_hash['slider-data-taxons'])
