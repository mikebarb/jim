class AddIndexToOrders < ActiveRecord::Migration[5.0]
  def change
    add_index :orders, [:product_id, :shop_id, :day], unique:true
  end
end
