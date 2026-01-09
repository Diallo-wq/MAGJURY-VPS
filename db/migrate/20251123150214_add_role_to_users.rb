class AddRoleToUsers < ActiveRecord::Migration[7.0]
  def change
     add_column :users, :role, :string, default: "visiteur" 
     add_column :users, :nom, :string
    add_column :users, :prenom, :string  
    add_column :users, :blocked, :boolean
  end
end
