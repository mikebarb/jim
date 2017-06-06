class AddQuantityToOrderlog < ActiveRecord::Migration[5.0]
  def change
    add_column :orderlogs, :quantity, :integer
    add_column :orderlogs, :oldquantity, :integer
  end
end
