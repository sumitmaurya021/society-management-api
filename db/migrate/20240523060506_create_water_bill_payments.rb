class CreateWaterBillPayments < ActiveRecord::Migration[7.1]
  def change
    create_table :water_bill_payments do |t|
      t.date :month_year
      t.string :bill_name
      t.string :block
      t.integer :floor
      t.integer :room_number
      t.decimal :amount
      t.string :payment_method
      t.references :user, null: false, foreign_key: true
      t.references :water_bill, null: false, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
