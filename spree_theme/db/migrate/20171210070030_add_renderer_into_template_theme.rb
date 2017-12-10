class AddRendererIntoTemplateTheme < ActiveRecord::Migration
  def change
    #目前 template_theme是调用一个方法生成页面，define_compiled_template_theme_method
    #希望可以使用正常的方式，解析erb文件生成页面，
    #renderer 0: 调用方法生成页面， 1：新的解析erb文件生成页面
    add_column :spree_template_themes, :renderer, :integer, null: false, default: 0
  end

end
