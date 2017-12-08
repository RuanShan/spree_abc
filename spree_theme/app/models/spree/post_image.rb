# a post could have several attachments
class Spree::PostImage < Spree::Asset

  #attr_accessible :alt, :attachment

  has_attached_file :attachment,
    :url => '/shops/:rails_env/:site/:class/:id/:basename_:style.:extension',
    :path => ':rails_root/public/shops/:rails_env/:site/:class/:id/:basename_:style.:extension'
  validates_attachment :attachment,
      :presence => true,
      :content_type => { :content_type => %w(image/jpeg image/jpg image/png image/gif) }


end
