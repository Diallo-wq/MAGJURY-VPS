# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true
  has_many   :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy
  validates  :body, presence: true, length: { minimum: 2 }
  validate   :name_or_user

  scope :roots, -> { where(parent_id: nil) }
  scope :flagged, -> { where(flagged: true) }

  def name
    user&.nom_complet || guest_name
  end

  def avatar_attached?
    user&.profile&.attached?
  end

  private

  def name_or_user
    errors.add(:base, "Nom ou utilisateur requis") if user.nil? && guest_name.blank?
  end
end