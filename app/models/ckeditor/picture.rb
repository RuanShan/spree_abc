class Ckeditor::Picture < Ckeditor::Asset
  has_attached_file :data,
                    :url  => "/shops/:rails_env/:site/ckeditor_assets/pictures/:id/:style_:basename.:extension",
                    :path => ":rails_root/public/shops/:rails_env/:site/ckeditor_assets/pictures/:id/:style_:basename.:extension",
                    :styles => { :content => '800>', :thumb => '118x100#' },
                    :default_style => :original

  validates_attachment_presence :data
  validates_attachment_size :data, :less_than => 2.megabytes
  validates_attachment_content_type :data, :content_type => /\Aimage/

  def url_content
    url(:original)
  end
end
