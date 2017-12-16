# select page base on current taxon
Rails.logger.debug "current_page=#{@current_page}"
render file: @current_page.released_page_path
