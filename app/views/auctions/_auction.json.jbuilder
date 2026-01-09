json.extract! auction, :id, :titre, :description, :prix_depart, :prix_actuel, :nombre_mises, :statut, :debut, :fin, :localisation, :user_id, :created_at, :updated_at
json.url auction_url(auction, format: :json)
