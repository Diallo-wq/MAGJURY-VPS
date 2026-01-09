class Category < ApplicationRecord
  has_many :posts, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  before_save { name.strip! }
end