class CreateShops < ActiveRecord::Migration[5.0]
  def change
    create_table :shops do |t|
      t.string :name
      t.text :address
      t.string :suburb
      t.string :postcode
      t.string :contact
      t.string :phone
      t.string :email
      t.text :note

      t.timestamps
    end
  end
end
