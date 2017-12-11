module SpreeMultiSite

  # include into model
  module PaperclipAliyunOssHelper
    # original path and url
    # :url  => "/shops/:rails_env/:site/ckeditor_assets/pictures/:id/:style_:basename.:extension",
    # :path => ":rails_root/public/shops/:rails_env/:site/ckeditor_assets/pictures/:id/:style_:basename.:extension",

    def self.extended( base )
      if base.storage_aliyun?
        base.fix_path_for_aliyun_oss
      end
    end

    def fix_path_for_aliyun_oss
      # ex. Spree::Taxon   path = 1/taxon/1_test.jpg,  :aliyun_style start with @
      # taxon/post/
      path = ":site/:simple_class/:id_:filename"
      #make sure each
      attachment_key = :attachment  # spree_image/ spree_template_file
      attachment_key = :icon if self.name == AttachmentClassEnum.spree_taxon
      attachment_key = :cover if self.name == AttachmentClassEnum.spree_post
      attachment_key = :data if self.name == AttachmentClassEnum.ckeditor_picture  #Ckeditor::Picture,
      attachment_key = :data if self.name == AttachmentClassEnum.ckeditor_file     #Ckeditor::AttachmentFile
      attachment_definitions[attachment_key][:path] = path
      attachment_definitions[attachment_key][:url] = 'http://:aliyun_host/'+path+':aliyun_style'
      attachment_definitions[attachment_key][:styles] = {} #no need styles anymore. it is supproted by oss style
    end

    def storage_aliyun?
     (attachment_definitions[:storage]||Paperclip::Attachment.default_options[:storage]) == :aliyun
    end
  end

end
