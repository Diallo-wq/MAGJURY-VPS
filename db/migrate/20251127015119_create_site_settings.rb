class CreateSiteSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :site_settings do |t|
      t.string :site_name
      t.string :logo
      t.string :currency
      t.string :time_zone
      t.string :tel1
      t.string :tel2
      t.string :whatsapp
      t.string :facebook
      t.string :linkedin
      t.string :instagram
      t.string :tiktok
      t.string :youtube
      t.string :twitter
      t.string :localisation
      t.string :devise
      t.string :description
      t.string :site_email

      t.timestamps
    end
  end
end
