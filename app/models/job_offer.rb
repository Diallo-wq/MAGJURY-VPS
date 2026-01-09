# app/models/job_offer.rb
class JobOffer < ApplicationRecord
  enum contract_type: { cd: 0, cdi: 1, cdd: 2, stage: 3, alternance: 4, freelance: 5 }, _prefix: :contract
  enum active: { archived: 0, published: 1 }, _default: :published

  scope :published, -> { where(active: :published) }
  scope :recent, -> { order(created_at: :desc) }

  # Badge couleur
  def badge_color
    { archived: "secondary", published: "success" }[active.to_sym]
  end

  # Texte du bouton WhatsApp
  def whatsapp_message
    "Bonjour, je suis intéressé par l’offre : #{title} (#{company})."
  end
end