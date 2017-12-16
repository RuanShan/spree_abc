class Spree::PostCategoriesController < Spree::BaseController
  
  include SpreeEssentialBlog::PostsControllerHelper

  before_action :get_sidebar, :only => [:index, :search, :show]
  
  def show
    @category = Spree::PostCategory.find_by_permalink(params[:id])
    @posts = @category.posts.live
    @posts = @posts.page(params[:page]).per(Spree::Post.per_page)
  end
  
end
