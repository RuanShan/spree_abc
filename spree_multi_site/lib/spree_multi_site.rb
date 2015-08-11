require 'spree_core'
require 'spree_multi_site/engine'
require 'spree_multi_site/multi_site_system'
require 'spree_multi_site/paper_clip_interpolate_site'
require 'spree_multi_site/permalinks'
require 'spree_multi_site/middleware'
require 'spree_multi_site/environment'
require 'spree_multi_site/permitted_attributes_for_site'
require 'spree_multi_site/paperclip_aliyun_oss_helper'


module SpreeMultiSite
  # these keys are alipay oss folder names
  AttachmentClassEnum = Struct.new(:spree_taxon, :spree_post, :spree_image, :ckeditor_picture, :ckeditor_file, :spree_template_file )\
    ['Spree::Taxon','Spree::Post','Spree::Image', 'Ckeditor::Picture','Ckeditor::AttachmentFile', 'Spree::TemplateFile']
end
