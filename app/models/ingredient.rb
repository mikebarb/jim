class Ingredient < ApplicationRecord
    validates :item, :unit, presence: true
    validates :item, uniqueness: true
    
    has_many :recipes
    has_many :products, through: :recipes
    
    before_destroy :ensure_not_referenced_by_any_recipe

    private
        # ensure that there are no recipes referencing this ingredient
        def ensure_not_referenced_by_any_recipe
            unless recipes.empty?
                errors.add(:base, ' - recipes present for this ingredient')
                throw :abort
            end
        end
end
