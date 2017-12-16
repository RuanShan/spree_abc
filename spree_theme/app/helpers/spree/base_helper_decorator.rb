module Spree
  module BaseHelper
    private
    # override original, always return style  for feature :aliyun_oss
    # Returns style of image or nil
    def image_style_from_method_name(method_name)
      if method_name.to_s.match(/_image$/) && style = method_name.to_s.sub(/_image$/, '')
        #possible_styles = Spree::Image.attachment_definitions[:attachment][:styles]
        #style if style.in? possible_styles.with_indifferent_access
        style
      end
    end

  end
end
