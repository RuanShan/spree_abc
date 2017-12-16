class Spree::Admin::PostFilesController < Spree::Admin::ResourceController

  before_action :load_data

  create.before :set_viewable
  update.before :set_viewable
  destroy.before :destroy_before

  private

  def location_after_save
    admin_post_files_url(@post)
  end

  def load_data
    @post = Spree::Post.friendly.find(params[:post_id])
  end

  def set_viewable
    @post_file.viewable = @post
  end

  def destroy_before
    @viewable = @post_file.viewable
  end

end
