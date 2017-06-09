class AddSectorToProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :products, :sector, foreign_key: true
  end
end
