class CreateIngredients < ActiveRecord::Migration[5.0]
  def change
    create_table :ingredients do |t|
      t.string :item
      t.string :unit

      t.timestamps
    end
    add_index :ingredients, :item
  end
end
