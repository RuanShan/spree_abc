unless Paperclip::Interpolations.all.include? :site
  Paperclip.interpolates :site do |attachment, style_name|
    attachment.instance.site_id # site.current do not work anymore, since we assign theme product to taxon of shop1.
  end
end