class Order < ApplicationRecord
  belongs_to :product
  belongs_to :shop
  belongs_to :user
  
  def self.dayshop(day, shop_id)
    where("day = ? and shop_id = ?", day, shop_id)
  end
  
end
