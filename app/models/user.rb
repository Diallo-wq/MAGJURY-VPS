class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[visiteur abonne redacteur admin super_admin bidder]

  enum status: { pending: 0, approved: 1, rejected: 2 }
  validates :password, presence: true, if: :password_required?

  has_many :auctions
  has_many :bids

  validates :role, inclusion: { in: ROLES }

  def has_role?(requested_role)
    role == requested_role.to_s
  end


  enum contributor: { normal: false, contributor: true }, _prefix: :contrib

  scope :contributors, -> { where(contributor: true) }

  def full_name
    "#{prenom} #{nom}".presence || email.split("@").first.humanize
  end

  def social_links
    {
      linkedin: linkedin,
      twitter: twitter,
      facebook: facebook,
      instagram: instagram,
      tiktok: tiktok
    }.compact
  end

  has_many :posts
  has_many :products

  has_one_attached :profile

  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= 'visiteur'
  end

   def super_admin?
    role == 'super_admin'
  end

  def admin?
    role == 'admin'
  end

  def bidder?
    role == 'bidder'
  end


  def abonne?
    role == 'abonne'
  end

  def redacteur?
    role == 'redacteur'
  end

  def nom_complet
    "#{nom} #{prenom}"
  end

  def initiales
    "#{prenom&.first&.upcase}#{nom&.first&.upcase}"
  end

  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end

  # Nouvelles relations pour les enchères
  has_many :bids, dependent: :destroy
  has_many :auctions, through: :bids
  has_many :watchlists, dependent: :destroy
  has_many :watched_auctions, through: :watchlists, source: :auction
  
  # Méthodes pour les enchères
  def active_bids
    bids.joins(:auction).where(auctions: { status: :live })
  end
  
  def won_auctions
    auctions.ended.joins(:bids)
            .where(bids: { amount: auctions.select('MAX(bids.amount)') })
            .distinct
  end

end
