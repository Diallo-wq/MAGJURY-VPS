# app/models/bid.rb
class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :auction

  validates :montant, presence: true, numericality: { greater_than: 0 }
  validate :montant_suffisant
  validate :encherisseur_approuve
  validate :vente_en_cours

  private

  def montant_suffisant
    return unless auction && montant
    if montant <= auction.prix_actuel
      errors.add(:montant, "doit être supérieur à la mise actuelle")
    end
  end

  def encherisseur_approuve
    return unless user
    unless user.approved?
      errors.add(:base, "Votre compte doit être validé par l’administrateur.")
    end
  end

  def vente_en_cours
    return unless auction
    unless auction.en_cours?
      errors.add(:base, "Cette vente n’est plus ouverte.")
    end
  end
end