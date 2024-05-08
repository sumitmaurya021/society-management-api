class AddPaymentModeToWaterBills < ActiveRecord::Migration[7.1]
  def change
    add_column :water_bills, :payment_mode, :integer
  end
end
