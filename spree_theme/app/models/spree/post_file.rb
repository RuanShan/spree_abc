# a post could have several attachments
class Spree::PostFile < Spree::Asset

  #attr_accessible :alt, :attachment

  has_attached_file :attachment,
                    :url => "/shops/:rails_env/:class/:id/:filename",
                    :path => ":rails_root/public/shops/:rails_env/:class/:id/:filename"

  validates_attachment :attachment,    presence: true,
    content_type: { content_type: %w(image/jpeg image/gif image/png text/plain application/vnd.ms-powerpoint application/msword aplication/zip application/pdf) },
    size: { in: 0..20.megabytes }

  def url_thumb
    @url_thumb ||= Ckeditor::Utils.filethumb(attachment_file_name)
  end
end
