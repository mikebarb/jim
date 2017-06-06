class CreateOrderlogs < ActiveRecord::Migration[5.0]
  def change
    create_table :orderlogs do |t|
      t.references :product, foreign_key: true
      t.references :shop, foreign_key: true
      t.date :day
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
