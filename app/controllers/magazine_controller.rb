# app/controllers/magazine_controller.rb
class MagazineController < ApplicationController
  def index
    # Récupère 4 articles featured pour le slider
    @featured = Post.published.featured.includes(:category, :user).limit(4)
    
    @categories = Category.left_outer_joins(:posts)
                          .where(posts: { status: :published })
                          .distinct
                          .select('categories.*, COUNT(posts.id) AS posts_count')
                          .group('categories.id')
                          .order('posts_count DESC')
    
    @popular_posts = Post.published.order(views: :desc).limit(5)
    
    if params[:category_id].present?
      @selected_category = Category.find_by(id: params[:category_id])
      @posts = @selected_category ? @selected_category.posts.published.with_featured_first.limit(12) : Post.published.with_featured_first.limit(12)
    else
      @posts = Post.published.with_featured_first.limit(12)
    end
  end
end