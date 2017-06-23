class AddIndexToUsershop < ActiveRecord::Migration[5.0]
  def change
    add_index :usershops, [:user_id, :shop_id], unique:true
  end
end
