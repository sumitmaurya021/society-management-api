class AddWaterBillIdInPayment < ActiveRecord::Migration[7.1]
  def change
    add_reference :payments, :water_bill, null: false, foreign_key: true
  end
end
