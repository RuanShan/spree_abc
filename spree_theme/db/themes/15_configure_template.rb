#################################  template resource #####################################
template = Spree::TemplateTheme.first

main_menu_section = template.page_layouts.where(:title=>'Main menu').first

template_files = template.template_files
title="Logo"
logo_section = template.page_layouts.where(:title=>title).first
logo_file = template_files.select{|file| file.attachment_file_name=~/logo/ }.first
template.assign_resource(logo_file, logo_section)


#################################  template css #####################################
ActiveRecord::Base.connection.reconnect!
# strange it always  'Lost connection to MySQL server' here
html_page = template.html_page
for partial_html in html_page.partial_htmls
  case partial_html.page_layout.title
  when 'Header'
    partial_html['block_height']['unset'] = true
    partial_html['block_height'].update
  when 'Main menu'
    partial_html['inner_background-color']['pvalue'] = '#D74700'
    partial_html['inner_background-color'].update
  when 'content'
    partial_html['block_height']['unset'] = true
    partial_html['block_height'].update
    partial_html['content_layout_clear']['unset'] = false
    partial_html['content_layout_clear']['psvalue'] = 'none'
    partial_html['content_layout_clear'].update

  when 'main content'
    partial_html['block_height']['unset'] = true
    partial_html['block_height'].update
    partial_html['block_width']['pvalue'] = 600
    partial_html['block_width']['unit'] = 'px'
    partial_html['block_width'].update
  when 'Others','Login','Account','Signup', 'product list', 'product detail', 'product', 'left part', 'right part'
    partial_html['block_height']['unset'] = true
    partial_html['block_height'].update

  when 'lftnav'
    partial_html['block_height']['unset'] = true
    partial_html['block_height'].update
    partial_html['block_width']['pvalue'] = 200
    partial_html['block_width']['unit'] = 'px'
    partial_html['block_width'].update
    partial_html['inner_background-color']['pvalue'] = '#FFF8ED'
    partial_html['inner_background-color'].update
  when 'footer'
    partial_html['inner_background-color']['pvalue'] = '#F5F5F5'
    partial_html['inner_background-color'].update
  end
end
