class Lockday < ApplicationRecord
    validates :day, uniqueness: true
    
    belongs_to :user
end
