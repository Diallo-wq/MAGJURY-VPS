class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :guest_name
      t.string :guest_email
      t.text :body
      t.integer :parent_id

      t.timestamps
    end
  end
end
