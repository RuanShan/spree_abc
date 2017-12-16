require 'spec_helper'
describe Spree::PageLayout do
  let (:page_layout) { create(:page_layout) }
  let (:context_detail) {  Spree::PageLayout::ContextEnum.detail }
  let (:context_list) {  Spree::PageLayout::ContextEnum.list }
  let (:context_cart) {  Spree::PageLayout::ContextEnum.cart }
  let (:context_either) {  Spree::PageLayout::ContextEnum.either }
  let (:context_thanks) {  Spree::PageLayout::ContextEnum.thanks }

  context 'with context product list and detail' do
    before(:each) do
      @page_layout = create(:page_layout, section_context: "#{context_list},#{context_detail}" )
    end

    it 'should has list and detail context' do
      @page_layout.current_contexts.should eq ([context_list,context_detail])
    end

    it "valid section context" do
      @page_layout.valid_context?(context_detail).should be_truthy
      @page_layout.context_detail?.should be_truthy
      @page_layout.context_list?.should be_truthy
    end

    context 'with one child' do
      it "should inherit context" do

      end
    end
  end

  it "could update context" do
    new_contexts = [context_cart]
    page_layout.update_section_context new_contexts
    page_layout.current_contexts.should eq(new_contexts)
  end

  it "could verify contexts" do
    Spree::PageLayout.verify_contexts( context_cart, [context_cart, context_thanks ] ).should be_truthy

    Spree::PageLayout.verify_contexts( [context_cart], [context_cart, context_thanks ] ).should be_truthy

    Spree::PageLayout.verify_contexts( context_either, [context_cart, context_thanks ] ).should be_truthy
  end


end
