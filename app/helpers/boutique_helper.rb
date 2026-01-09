# app/helpers/boutique_helper.rb
module BoutiqueHelper
  # vos méthodes ici
  def couleur_statut_produit(status)
    { in_stock: "success", limited: "warning", out_of_stock: "secondary" }[status.to_sym]
  end

  def couleur_statut_produit(status)
  { in_stock: "success", limited: "warning", out_of_stock: "secondary" }[status.to_sym]
end

end