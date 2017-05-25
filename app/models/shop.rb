class Shop < ApplicationRecord
    validates :name, :contact, :phone, :email, presence: true
    validates :name, uniqueness: true
end
