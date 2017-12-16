#覆盖 spree_editor 中原文件，修改 current_editor，ids 缺省值
module Spree
  class EditorSetting < Preferences::Configuration
    preference :enabled,        :boolean, default: true
    preference :current_editor, :string,  default: 'CKEditor'
    preference :ids,            :string,  default: 'product_description page_body taxon_description template_text_body post_body'

    def self.editors
      %w(TinyMCE CKEditor)
    end
  end
end
