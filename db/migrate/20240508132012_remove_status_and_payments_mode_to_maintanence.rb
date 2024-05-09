class RemoveStatusAndPaymentsModeToMaintanence < ActiveRecord::Migration[7.1]
  def change
    remove_column :maintenance_bills, :status
    remove_column :maintenance_bills, :payment_mode
  end
end
