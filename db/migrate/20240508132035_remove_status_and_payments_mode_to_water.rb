class RemoveStatusAndPaymentsModeToWater < ActiveRecord::Migration[7.1]
  def change
    remove_column :water_bills, :status
    remove_column :water_bills, :payment_mode
  end
end
