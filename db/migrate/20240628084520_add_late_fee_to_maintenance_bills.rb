class AddLateFeeToMaintenanceBills < ActiveRecord::Migration[7.1]
  def change
    add_column :maintenance_bills, :late_fee, :decimal, default: 0
  end
end
