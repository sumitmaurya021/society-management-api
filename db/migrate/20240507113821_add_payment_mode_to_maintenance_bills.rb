class AddPaymentModeToMaintenanceBills < ActiveRecord::Migration[7.1]
  def change
    add_column :maintenance_bills, :payment_mode, :integer
  end
end
