class Sector < ApplicationRecord
    has_many :products 
    before_destroy :ensure_not_referenced_by_any_product

    private
        # ensure that there are no products referencing this sector
        def ensure_not_referenced_by_any_product
            unless products.empty?
                errors.add(:base, 'Cannot destroy - products present for this sector')
                throw :abort
            end
        end
end
