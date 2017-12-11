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
    Spree::MultiSiteSystem.unbind
    product = Spree::Product.new
    expect( product.site ).to be_nil
  end

  context 'threads' do
    it "should has default site scope " do
      puts "\n============================"
      puts "should has default site scope "
      puts "main thread"
      t = Thread.new do
        puts "--new thread"
        Spree::Site.current = site1
        Spree::MultiSiteSystem.bind
        puts "--new thread before sleep"
        sleep 0.1
        puts "--new thread after sleep"
        product = Spree::Product.new
        expect( product.site ).to eq( Spree::Site.current )
      end
      sleep 0.1
      puts "main thread before unbind"
      Spree::MultiSiteSystem.unbind
      puts "main thread before join"
      t.join
    end


    it "should has no default site scope " do
      puts "\n============================"
      puts "should has no default site scope "
      puts "main thread"
      t = Thread.new do
        puts "--new thread"
        Spree::Site.current = site2
        Spree::MultiSiteSystem.unbind
        puts "--new thread before sleep"
        sleep 0.1
        puts "--new thread after sleep"
        product = Spree::Product.new
        expect( product.site ).to be_nil
      end
      sleep 0.1
      puts "main thread before bind"
      Spree::MultiSiteSystem.bind
      puts "main thread before join"
      t.join
    end
  end

end
