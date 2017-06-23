class AddInactiveToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :inactive, :boolean
  end
end
