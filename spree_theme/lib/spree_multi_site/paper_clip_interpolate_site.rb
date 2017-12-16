module SpreeMultiSite

  unless Paperclip::Interpolations.all.include? :site

    Paperclip.interpolates :site do |attachment, style_name|
      #belongs to site: product
      #belongs to store: logo, favicon
      attachment.instance.try(:site_id) || attachment.instance.try(:store).try(:site_id) # site.current do not work anymore, since we assign theme product to taxon of shop1.
    end
    # Paperclip support :class,  Spree::Taxon => spree/taxon, with simple_class, Spree::Taxon => taxon
    Paperclip.interpolates :simple_class do |attachment, style_name|

      AttachmentClassEnum.to_h.key( attachment.instance.class.name ) || 'unkown'
      #attachment.instance.class.name.demodulize.underscore
    end

    Paperclip.interpolates :aliyun_host do |attachment, style_name|
      #style_name is symbol
      case style_name
        when :original
          Paperclip::Attachment.default_options[:aliyun][:oss_host]
        else
          Paperclip::Attachment.default_options[:aliyun][:img_host]
      end
    end

    # support aliyun image resize service
    # product image { mini: '48x48>', small: '100x100>', product: '240x240>', medium: '350x350>', large: '600x600>' }
    # post image { mini: '60x60>', small: '180x120>', medium: '280x190>', large: '670x370>'},
    # http://userdomain/object.jpg@100w_100h_90Q.jpg
    Paperclip.interpolates :aliyun_style do |attachment, style_name|
      extension = '.jpg'
      style_symbol = style_name.to_sym
      if attachment.instance.class.name == AttachmentClassEnum.spree_image
        case style_symbol
          when :mini
            '@48w_48h_1x' + extension
          when :small
            '@100w_100h_1x' + extension
          when :product
            '@240w_240h_1x' + extension
          when :medium
            '@350w_350h_1x' + extension
          when :large
            '@600w_600h_1x' + extension
        end
      elsif attachment.instance.class.name == AttachmentClassEnum.spree_post
        case style_symbol
          when :mini # post cover
            '@60w_60h_1x' + extension
          when :small
            '@180w_120h_1x' + extension
          when :medium
            '@280w_190h_1x' + extension
          when :large
            '@670w_370h_1x' + extension
        end
      elsif attachment.instance.class.name == AttachmentClassEnum.ckeditor_picture
        case style_symbol
          when :thumb   # ckeditor image, '118x100#', as list item
            #先把图按短边优先缩略，然后再用指定颜色填充剩余区域
            '@118w_100h_4e' + extension
          when :content # ckeditor image, '800>' , as editor content
            '@800w_l1' + extension
        end
      elsif attachment.instance.class.name == AttachmentClassEnum.spree_template_file
        case style_symbol
          when :mini
            #将图按短边缩略到48x48, 然后按白色填充
            '@48w_48h_4e' + extension
        end

      end

    end # :aliyun_style
  end

end # SpreeMultiSite
