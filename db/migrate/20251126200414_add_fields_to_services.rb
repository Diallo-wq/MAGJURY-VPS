class AddFieldsToServices < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :icon, :string
    add_column :services, :price, :decimal
    add_column :services, :price_suffix, :string
    add_column :services, :category, :string
  end
end
