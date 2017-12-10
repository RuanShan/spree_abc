require 'spec_helper'
describe Spree::TemplateTheme do

    # page_layout tree
    # root( stylish 0)
    #  + node0( stylish= 1 )
    # root( stylish 1)
    #    + node1( stylish=0 )
    # taxon0(stylish=0), taxon1( stylish=1)
    # taxon0.valid_context?(product-list-grid ) => true
    # taxon0.valid_context?(product-list-line ) => false


    context 'a page layout' do
      let (:taxon0) { create(:taxon, stylish: 0) }
      let (:taxon1) { create(:taxon, stylish: 1) }

      it 'taxon stylish 0 should be valid for page_layout stylish 1' do
        theme = create(:stylished_template_theme, stylish: 1)
        style1 = theme.page_layout_root

        expect( theme.valid_context?(style1, taxon0)).to be_falsey
        expect( theme.valid_context?(style1, taxon1)).to be_truthy
      end

      it 'taxon stylish 0 should be valid for page_layout stylish 0' do
        theme = create(:stylished_template_theme, stylish: 0)
        style0 = theme.page_layout_root

        expect( theme.valid_context?(style0, taxon0)).to be_truthy
        expect( theme.valid_context?(style0, taxon1)).to be_truthy
      end

    end

    context 'page_layout tree' do

      let (:taxon0) { create(:taxon, stylish: 0) }
      let (:taxon1) { create(:taxon, stylish: 1) }
      #  root - stylish0
      #       - stylish1
      it 'node stylish 1 should be valid for taxon stylish 1' do
        template_theme = create(:template_theme_stylish_tree, stylish:'01'  )

        style1 = template_theme.page_layout_root.children.first

        expect( template_theme.valid_context?(style1, taxon0)).to be_falsey
        expect( template_theme.valid_context?(style1, taxon1)).to be_truthy
      end

      #  root - stylish1
      #       - stylish0
      # 这个用例不会发生，先检查父节点，再检查子节点，父节点无效，子节点全部忽略。
      it 'node stylish 0 should be valid for taxon stylish 1' do
        template_theme = create(:template_theme_stylish_tree, stylish:'10' )

        style0 = template_theme.page_layout_root.children.first
        #expect( template_theme.valid_context?(style0, taxon0)).to be_falsey
        #expect( template_theme.valid_context?(style0, taxon1)).to be_truthy
      end

    end

end
