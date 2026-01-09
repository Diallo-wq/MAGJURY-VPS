class AddContributorFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :bio, :text
    add_column :users, :linkedin, :string
    add_column :users, :twitter, :string
    add_column :users, :facebook, :string
    add_column :users, :instagram, :string
    add_column :users, :tiktok, :string
    add_column :users, :contributor, :boolean, default:false
    add_column :users, :profession, :string
    add_column :users, :domaine, :string
  end
end
