# app/models/service.rb
class Service < ApplicationRecord
  enum category: { debutant: "populaire", expert: "expert", nouveau: "nouveau" }, _prefix: :cat

  validates :title, :description, presence: true
  validates :category, inclusion: { in: categories.keys, allow_nil: true }

  
end