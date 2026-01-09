class AddImageToAuctions < ActiveRecord::Migration[7.0]
  def change
    add_column :auctions, :image, :string
  end
end
