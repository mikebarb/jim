class User < ApplicationRecord
  has_secure_password
  before_destroy :ensure_not_referenced_by_any_order_or_orderlog
  
  validates :email, uniqueness: true
  
  has_many :usershops, dependent: :destroy
  has_many :shops, through: :usershops
  has_many :lockdays
  has_many :orders
  has_many :orderlogs
  


    private
        # ensure that there are no orders referencing this user
        def ensure_not_referenced_by_any_order_or_orderlog
            unless orders.empty?
                errors.add(:base, 'Cannot destroy - orders present for this user')
                throw :abort
            end
            unless orderlogs.empty?
                errors.add(:base, 'Cannot destroy - orderlog entries present for this user')
                throw :abort
            end            
        end
end
