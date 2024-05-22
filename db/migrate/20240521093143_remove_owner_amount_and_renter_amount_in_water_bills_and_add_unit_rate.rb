class RemoveOwnerAmountAndRenterAmountInWaterBillsAndAddUnitRate < ActiveRecord::Migration[7.1]
  def change
    remove_column :water_bills, :owner_amount
    remove_column :water_bills, :rent_amount
    add_column :water_bills, :unit_rate, :decimal
  end
end
