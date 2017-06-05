class CreateRecipes < ActiveRecord::Migration[5.0]
  def change
    create_table :recipes do |t|
      t.belongs_to :product, foreign_key: true
      t.belongs_to :ingredient, foreign_key: true
      t.integer :amount

      t.timestamps
    end
  end
end
