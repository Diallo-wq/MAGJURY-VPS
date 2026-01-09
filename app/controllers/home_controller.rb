class HomeController < ApplicationController
  def accueil
    @services = Service.order(created_at: :asc).limit(6)
    @products = Product.includes(:product_category).order(created_at: :desc).limit(3)
    @posts = Post.published.limit(3)
  end
end
