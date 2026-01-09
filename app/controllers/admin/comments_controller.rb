# app/controllers/admin/comments_controller.rb
class Admin::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_redacteur!
  layout 'dashboard'

  def index
    @comments = Comment.includes(:user, :post)
                       .order(created_at: :desc)
    filter_collection if params[:commit].present?
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.toggle!(:flagged) # ou tout autre champ
    redirect_to admin_comments_path, notice: "Commentaire mis à jour."
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to admin_comments_path, alert: "Commentaire supprimé."
  end

  private

  def filter_collection
    @comments = @comments.where(post_id: params[:post_id]) if params[:post_id].present?
    @comments = @comments.where(flagged: true)             if params[:flagged] == "1"
    @comments = @comments.where("body ILIKE ?", "%#{params[:q]}%") if params[:q].present?
  end
end