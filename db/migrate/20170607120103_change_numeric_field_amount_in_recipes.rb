class ChangeNumericFieldAmountInRecipes < ActiveRecord::Migration[5.0]
  def self.up
    change_column :recipes, :amount, :decimal, :precision => 12, :scale => 4
  end
end
