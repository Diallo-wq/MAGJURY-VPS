json.extract! product, :id, :title, :description, :price, :reduced_price, :status, :stock, :product_category_id, :created_at, :updated_at
json.url product_url(product, format: :json)
