# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:flag]
  before_action :set_comment, only: [:flag]

  def create
    Rails.logger.debug "======== params = #{params.inspect} ========"
    @post = Post.find_by!(slug: params[:post_slug])
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user if user_signed_in?

    if @comment.save
      render partial: 'comments/comment', locals: { comment: @comment }
    else
      render partial: 'comments/errors', locals: { comment: @comment }, status: :unprocessable_entity
    end
  end

  def flag
    @comment.update(flagged: true)
    head :ok
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :guest_name, :guest_email, :parent_id)
  end
end