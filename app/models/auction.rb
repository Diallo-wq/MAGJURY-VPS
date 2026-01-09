# app/models/auction.rb
class Auction < ApplicationRecord
  belongs_to :user
  has_many :bids, dependent: :destroy
  has_one_attached :image
  enum statut: { brouillon: 0, bientot: 1, en_cours: 2, terminee: 3 }, _default: :brouillon

  before_validation :init_prix_actuel, on: :create

  def init_prix_actuel
    self.prix_actuel ||= prix_depart
  end

scope :publiques, -> { where.not(statut: :brouillon) }

def temps_avant_ouverture
  return 0 if brouillon? || en_cours? || terminee?
  [(debut - Time.current).to_i, 0].max
end

def temps_restant
  return 0 if terminee? || fin.past?
  [(fin - Time.current).to_i, 0].max
end

def may_start?
  bientot? && debut.past?
end

def may_close?
  en_cours? && fin.past?
end

end