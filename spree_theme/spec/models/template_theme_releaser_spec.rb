require 'spec_helper'
describe Spree::TemplateTheme do
  let (:template_theme) {  create :previewable_template_theme }
  let (:template_theme_renderer_page) {  create :previewable_template_theme, renderer: :renderer_page }

  it "could relese" do
    #serializable_data = template.serializable_data
    #new_theme = Spree::TemplateTheme.import_into_db(serializable_data)
    #page_layouts = new_theme.page_layouts
    #page_layouts.size.should == serializable_data['page_layouts'].size
    #template_file same
    #template.assigned_resource_ids updated for new resource_id, like template_file

    template_theme.release



  end


  it "could relese" do
    #serializable_data = template.serializable_data
    #new_theme = Spree::TemplateTheme.import_into_db(serializable_data)
    #page_layouts = new_theme.page_layouts
    #page_layouts.size.should == serializable_data['page_layouts'].size
    #template_file same
    #template.assigned_resource_ids updated for new resource_id, like template_file

    template_theme_renderer_page.release

  end

end
