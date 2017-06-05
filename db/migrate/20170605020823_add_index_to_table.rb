class AddIndexToTable < ActiveRecord::Migration[5.0]
  def change
    add_index :recipes, [:product_id, :ingredient_id], unique:true
  end
end
