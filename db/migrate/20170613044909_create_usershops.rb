class CreateUsershops < ActiveRecord::Migration[5.0]
  def change
    create_table :usershops do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :shop, foreign_key: true

      t.timestamps
    end
  end
end
