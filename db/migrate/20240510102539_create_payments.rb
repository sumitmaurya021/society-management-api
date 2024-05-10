class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.date :month_year
      t.string :bill_name
      t.string :block
      t.integer :floor
      t.string :room_number
      t.decimal :amount
      t.string :payment_method
      t.string :payment_status

      t.timestamps
    end
  end
end
