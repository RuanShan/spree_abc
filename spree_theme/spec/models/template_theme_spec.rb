require 'spec_helper'
describe Spree::TemplateTheme do
  let (:template) { create :template_theme }
  let (:page_layout_root) { template.page_layout_root}
  let (:section_root) { create :section_root }

  before(:each) do
    create(:store)
    @taxon = create(:taxon)
  end

  it "should has valid context" do
    taxon = @taxon
    template.valid_context?( page_layout_root, taxon ).should be_truthy
  end

  it "has document_path" do
    #template.original_template_theme.store.path
    template.original_template_theme.should eq template
  end

  it "param_values" do
    template.respond_to?(:param_values).should be_truthy
  end

  it "be destroy" do
    #test destroy
  end

  it "create plain template" do
    template = Spree::TemplateTheme.create_plain_template(section_root,'Template One')
    template.should be_an_instance_of(Spree::TemplateTheme)
    page_layout_root.should be_an_instance_of(Spree::PageLayout)
    page_layout_root.root?.should be_truthy
    #TODO check param_values
  end

  context "assign template file" do
    before(:each) do
      @template_file = create(:template_file)
    end

    it "should assign resource" do
      template_file = @template_file
      template.assign_resource( template_file, page_layout_root )
      template.assign_resource( template_file, page_layout_root, 1 )
      template.assigned_resource_id( Spree::TemplateFile, page_layout_root ).should eq template_file.id
      template.assigned_resource_id( Spree::TemplateFile, page_layout_root, 1 ).should eq template_file.id

      template_resources = template.template_resources
      template_resources.should be_present
    end

    it "should unassign resource" do
      template_file = @template_file
      template.assign_resource( template_file, page_layout_root )
      template.unassign_resource( Spree::TemplateFile, page_layout_root )
      template.assigned_resource_id( Spree::TemplateFile, page_layout_root ).should eq 0

      template.assigned_resources( Spree::TemplateFile, page_layout_root ).compact.should be_blank
    end

  end

  it "should update release id" do
    template_release = template.template_releases.build
    template_release.name = "just a test"
    template_release.save!

    template.reload

    template.release_id.should == template_release.id
  end

  it "assign attributes" do
    original_title = "it is test"
    theme = Spree::TemplateTheme.new(:title=>original_title)
    theme.attributes = {:assigned_resource_ids=>{}, :template_files=>[]}
    theme.title.should == original_title
  end

  it "should be imported" do
    #open(File.join( SpreeTheme::Engine.root,'db', 'themes', 'template_images', 'logo.gif')) do|f|
    #  template_file = Spree::TemplateFile.new(:attachment=>f, :page_layout_id=>template.page_layout_root_id)
    #  new_template = template.import(:template_files => [template_file] )
    #  new_template.current_template_release.should be_present
    #  new_template.should be_a_kind_of Spree::TemplateTheme
    #  new_template.assigned_resources( Spree::TemplateFile,page_layout_root ).should be_present
    #end
  end


  context 'assigned specific taxon' do
    before(:each) do
      @specific_taxon = create(:specific_taxon)
      template.assign_resource( @specific_taxon, page_layout_root )
    end

    it "should get assigned specific taxon" do
      taxon = @specific_taxon
      template.assigned_resource_id( taxon.class, page_layout_root ).should eq taxon.id
    end

    it "should has invalid context for other taxon" do
      another_taxon = @taxon
      template.valid_context?( page_layout_root, another_taxon ).should be false
    end

    it "should unassign resource from theme after taxon destroy" do
      taxon = @taxon
      template.assign_resource( taxon, page_layout_root )
      taxon.destroy
      template.reload
      template.assigned_resource_id( taxon.class, page_layout_root ).should eq 0
    end
  end


end
