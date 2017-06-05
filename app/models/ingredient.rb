class Ingredient < ApplicationRecord
    validates :item, :unit, presence: true
    validates :item, uniqueness: true
    
    has_many :recipes
    has_many :products, through: :recipes
end
