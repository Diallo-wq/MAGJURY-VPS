class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :comments, dependent: :destroy
  has_one_attached :cover_image
  after_validation :keep_typed_values

  scope :featured, -> { where(featured: true) }
  scope :with_featured_first, -> { order(featured: :desc, created_at: :desc) }
  
  validates :title, :content, presence: true

  attr_accessor :new_category_name, :new_tag_names

  before_validation :create_category_if_needed
  before_validation :sync_tags
  validate :category_must_be_present
  before_validation :resolve_category

  enum status: { draft: 0, published: 1 }, _default: :draft
  
  def increment_views
    increment!(:views)
  end

  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  before_validation :generate_slug
  before_save       :normalize_slug

  def to_param
    slug
  end

  private

  def create_category_if_needed
    if new_category_name.present?
      self.category = Category.find_or_create_by(name: new_category_name.strip)
    end
  end

  def category_must_be_present
    if category.nil? && new_category_name.blank?
      errors.add(:new_category_name, "doit être renseignée (choisir ou créer)")
    end
  end

  def sync_tags
    return if new_tag_names.nil?

    # normalise la liste
    wanted_names = new_tag_names.split(',').map(&:strip).reject(&:blank?).uniq

    # trouve ou crée chaque tag
    wanted_tags = wanted_names.map do |name|
      Tag.find_or_create_by(name: name.downcase)
    end

    # remplace la collection par celle-ci (associations automatiquement mises à jour)
    self.tags = wanted_tags
  end
  
  def resolve_category
    # 1) priorité au menu déroulant
    return if category_id.present?

    # 2) sinon on regarde ce qui est tapé
    return if new_category_name.blank?

    # on cherche sans tenir compte de la casse
    cat = Category.where('LOWER(name) = ?', new_category_name.strip.downcase).first

    if cat
      self.category = cat        # on ré-utilise l’existante
    else
      self.category = Category.new(name: new_category_name.strip)
    end
  end

  def keep_typed_values
    # si on a déjà rempli ces champs on ne les perd pas
    @new_category_name ||= category&.name
    @new_tag_names    ||= tags.map(&:name).join(', ')
  end

   # génération automatique si le champ est vide
  def generate_slug
    return if slug.present?
    return if title.blank?

    base = title
             .parameterize                 # "Mon super titre" -> "mon-super-titre"
             .presence || "post"

    slug_candidate = base
    counter = 2
    while Post.exists?(slug: slug_candidate)
      slug_candidate = "#{base}-#{counter}"
      counter += 1
    end
    self.slug = slug_candidate
  end

  def normalize_slug
    self.slug = slug&.parameterize
  end

end