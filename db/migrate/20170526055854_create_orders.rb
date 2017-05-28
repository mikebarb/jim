class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.belongs_to :product, foreign_key: true
      t.belongs_to :shop, foreign_key: true
      t.date :day
      t.integer :quantity
      t.boolean :locked
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :orders, :day
  end
end
