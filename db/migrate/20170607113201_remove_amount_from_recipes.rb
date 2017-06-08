class RemoveAmountFromRecipes < ActiveRecord::Migration[5.0]
  def change
    remove_column :recipes, :amount, :integer
  end
end
