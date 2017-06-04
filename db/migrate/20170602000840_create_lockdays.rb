class CreateLockdays < ActiveRecord::Migration[5.0]
  def change
    create_table :lockdays do |t|
      t.date :day
      t.boolean :locked
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :lockdays, :day
  end
end
