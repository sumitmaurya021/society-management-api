class ChangeNulTrueForMaintenenceBillAndWaterBillInPayments < ActiveRecord::Migration[7.1]
  def change
    change_column_null :payments, :maintenance_bill_id, true
    change_column_null :payments, :water_bill_id, true
  end
end
