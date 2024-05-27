class RemoveWaterBillIdInPayment < ActiveRecord::Migration[7.1]
  def change
    remove_column :payments, :water_bill_id
  end
end
