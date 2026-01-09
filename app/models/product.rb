# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :product_category, optional: true
  belongs_to :user
  enum status: { in_stock: 0, limited: 1, out_of_stock: 2 }, _default: :in_stock
 has_one_attached :image
  # Prix affiché
  def current_price
    reduced_price.present? && reduced_price > 0 ? reduced_price : price
  end

  # % réduction
  def discount_percent
    return 0 if reduced_price.blank? || reduced_price <= 0 || price <= 0
    ((price - reduced_price) / price * 100).round
  end

  # Stock virtuel
  def stock_display
    return "Rupture" if out_of_stock?
    return "Stock limité" if limited?
    "En stock"
  end
end