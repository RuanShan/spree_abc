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
    context 'tree with 2 stylish' do

      let( :template_theme_01) { create(:template_theme_stylish_01 ) }
      let (:taxon0) { create(:taxon, stylish: 0) }
      let (:taxon1) { create(:taxon, stylish: 1) }

      it 'should has three children, vary in stylish' do
        page_layout = template_theme_01.page_layout_root
        expect( page_layout.self_and_descendants.map(&:stylish).uniq.count ).to be( 2 )
      end

      it 'stylish 0 should be valid for stylish 1' do
        template_theme = template_theme_01

        style0 = template_theme.page_layout_root
        style1 = template_theme.page_layout_root.leaf

        expect( template_theme.valid_context?(style0, taxon0)).to be_truthy
        expect( template_theme.valid_context?(style1, taxon0)).to be_truthy
      end

    end

end
