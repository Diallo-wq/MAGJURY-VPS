# app/controllers/boutique_controller.rb
class BoutiqueController < ApplicationController
  # app/controllers/boutique_controller.rb
def index
  @products = Product.includes(:product_category).order(created_at: :desc)
  @categories = ProductCategory.order(:name)

  # Filtres
  @products = @products.where(product_category_id: params[:category]) if params[:category].present?
  @products = @products.where(status: :in_stock) if params[:en_stock] == "1"
  @products = @products.where("title ILIKE ?", "%#{params[:q]}%") if params[:q].present?

  # Tri
  @products = @products.order(price: :asc)  if params[:sort] == "price_asc"
  @products = @products.order(price: :desc) if params[:sort] == "price_desc"
end


end