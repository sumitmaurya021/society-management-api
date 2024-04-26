class CreateMaintenanceBills < ActiveRecord::Migration[7.1]
  def change
    create_table :maintenance_bills do |t|
      t.string :your_name
      t.string :name
      t.decimal :amount
      t.date :start_date
      t.date :end_date
      t.text :remarks
      t.references :building, null: false, foreign_key: true

      t.timestamps
    end
  end
end
