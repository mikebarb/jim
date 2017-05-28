class Shop < ApplicationRecord
    validates :name, :contact, :phone, :email, presence: true
    validates :name, uniqueness: true
    
    has_many :orders
    has_many :products, through: :orders
end
