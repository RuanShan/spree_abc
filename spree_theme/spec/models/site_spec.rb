#encoding: utf-8
require 'spec_helper'
describe Spree::Site do
  before(:each) do
    create(:admin_role)
    @site = Spree::Site.new(:name=>'ABCD',:domain=>'www.abc.net', :email=>'test@example.com', :password=>'123456')
  end

  it "should be valid with blank domain" do
    @site.domain = nil
    @site.should be_valid
  end

  it "named 'ABC' should not be valid" do
    @site.name = 'ABC'
    @site.short_name = nil
    @site.valid?.should be_falsy
  end

  it "generate 'da-lian-and-bai-jiu' from name '大连&白酒!'" do
    @site.name = '大连&白酒!'
    @site.short_name = nil
    @site.valid?.should be_truthy
    @site.short_name.should eq "da-lian-and-bai-jiu"
    @site.save.should be_truthy
  end

  it "should create site with store, user and shipping_category" do
    #user_attributes = {"email"=>"test@abc.com", "password"=>"a12345z", "password_confirmation"=>"a12345z"}
    #@site.users<< Spree::User.new(user_attributes)
    @site.save!
    @site.should be_persisted
    Spree::Site.current = @site
    @site.users.should be_present
    @site.stores.should be_present
  end

  # raise error ./app/models/spree/site.rb:56:in `current'
  #it "should create site and admin user" do
  #  site_params = { "name"=>"test", "short_name"=>"test",
  #        "users_attributes"=>{"0"=>{"email"=>"test@example.com", "password"=>"123456", "password_confirmation"=>"123456"}}
  #        }
  #  site = Spree::Site.new(site_params)
  #  site.save
  #  site.should_not be_new_record
  #end

  #it "shold load samples" do
  #  @site.save!
  #  @site.load_sample
  #  @site.shipping_categories.should be_present
  #  @site.users.first.should be_persisted
  #  @site.users.first.should be_admin
  #end

  it "shold remove samples" do
    @site.save!
    @site.unload_sample
    Spree::Site.current = @site
    Spree::Product.count.should eq(0)
    Spree::Zone.count.should eq(0)
    Spree::StateChange.count.should eq(0)
    #product variants
    #taxonomy, taxon
    #zone,zone_member
    #state_changes
  end

  it "shold create two site and load samples for them" do
    #@site1 = Spree::Site.create!(:name=>'Site1',:domain=>'www.site1.net',:short_name=>'site1', :email=>'site1@example.com', :password=>'123456')
    #@site2 = Spree::Site.create!(:name=>'Site1',:domain=>'www.site2.net',:short_name=>'site2', :email=>'site2@example.com', :password=>'123456')
    #@site1.load_sample
    #@site2.load_sample
    #product image copied and in right folder.
  end

end
