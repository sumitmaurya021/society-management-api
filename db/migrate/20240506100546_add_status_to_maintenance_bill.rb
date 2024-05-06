class AddStatusToMaintenanceBill < ActiveRecord::Migration[7.1]
  def change
    add_column :maintenance_bills, :status, :string, default: "pending"
  end
end
