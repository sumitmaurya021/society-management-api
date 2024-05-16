class ChaneNameOfColumnOfMaintenenceBills < ActiveRecord::Migration[7.1]
  def change
    rename_table :maintenancebills, :maintenance_bills
  end
end
