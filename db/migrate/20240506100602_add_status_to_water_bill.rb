class AddStatusToWaterBill < ActiveRecord::Migration[7.1]
  def change
    add_column :water_bills, :status, :string, default: "pending"
  end
end
