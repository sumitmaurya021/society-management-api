class CreateWaterBills < ActiveRecord::Migration[7.1]
  def change
    create_table :water_bills do |t|
      t.references :room, null: false, foreign_key: true
      t.references :building, null: false, foreign_key: true
      t.string :bill_name
      t.string :bill_month_and_year
      t.decimal :owner_amount
      t.decimal :rent_amount
      t.date :start_date
      t.date :end_date
      t.text :remarks

      t.timestamps
    end
  end
end
