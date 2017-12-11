#encoding: utf-8
require 'spec_helper'
describe Spree::Site do

  let(:site1) { create(:site1) }
  let(:site2) { create(:site2) }

  it "should has default site scope " do
    Spree::Site.current = site1

    Spree::MultiSiteSystem.bind
    product = Spree::Product.new
    expect( product.site ).to eq( Spree::Site.current )
  end


  #缺省状态为没有 scope，这样便于创建test_app,载入migration
  it "should has no default site scope by default " do
    Spree::Site.current = site1

    product = Spree::Product.new
    expect( product.site ).to be_nil
  end



end
