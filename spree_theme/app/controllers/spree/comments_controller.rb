module Spree
  class CommentsController < StoreController
    before_action :initialize_comment, :only => [:create, :new_to_site]

    def new_to_site
      @comment.commentable = Spree::Store.current
    end

    def create
      @comment.attributes =  permitted_resource_params
      if @comment.save
        flash[:success] = Spree.t(:comment_successfully_created)
        respond_with(@comment) do |format|
          format.html { redirect_to :back }
          format.js   { render :layout => false }
        end
      else
        respond_with(@comment)
      end
    end

    private

    def initialize_comment
      @comment = Comment.new(  )
      @comment.user = try_spree_current_user
    end

    def permitted_resource_params
      params.require('comment').permit( permitted_attributes.comment_attributes )
    end
  end

end
