class AddFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone, :string
    add_column :users, :address, :text
    add_column :users, :status, :integer, default: 0
  end
end
