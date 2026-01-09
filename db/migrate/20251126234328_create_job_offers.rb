class CreateJobOffers < ActiveRecord::Migration[7.0]
  def change
    create_table :job_offers do |t|
      t.string :title
      t.string :company
      t.string :location
      t.integer :contract_type
      t.boolean :remote
      t.string :salary
      t.text :description
      t.string :contact_phone
      t.integer :active

      t.timestamps
    end
  end
end
