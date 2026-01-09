class CreateAuctions < ActiveRecord::Migration[7.0]
  def change
    create_table :auctions do |t|
      t.string :titre
      t.text :description
      t.integer :prix_depart
      t.integer :prix_actuel
      t.integer :nombre_mises
      t.integer :statut
      t.datetime :debut
      t.datetime :fin
      t.string :localisation
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
