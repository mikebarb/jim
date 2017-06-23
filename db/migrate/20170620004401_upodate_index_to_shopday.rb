class UpodateIndexToShopday < ActiveRecord::Migration[5.0]
  def change
    remove_index :lockdays, [:day]
    add_index :lockdays, [:day], unique: true
  end
end
