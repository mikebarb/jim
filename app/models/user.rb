class User < ApplicationRecord
  has_secure_password
  validates :name, :password, :email, presence: true
  validates :email, uniqueness: true
end
