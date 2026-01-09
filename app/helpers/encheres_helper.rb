# app/helpers/encheres_helper.rb
module EncheresHelper
  def couleur_statut(statut)
    case statut
    when "bientot"    then "warning"
    when "en_cours"   then "danger"
    when "terminee"   then "dark"
    else "secondary"
    end
  end
end