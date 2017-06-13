class User < ApplicationRecord
  has_secure_password
  validates :email, uniqueness: true
  
  has_many :usershops
  has_many :shops, through: :usershops
end
