# app/models/product_category.rb
class ProductCategory < ApplicationRecord
  has_many :products, dependent: :nullify
end