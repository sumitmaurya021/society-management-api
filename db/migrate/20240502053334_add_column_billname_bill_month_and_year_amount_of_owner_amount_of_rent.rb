class AddColumnBillnameBillMonthAndYearAmountOfOwnerAmountOfRent < ActiveRecord::Migration[7.1]
  def change
    add_column :water_bills, :bill_name, :string
    add_column :water_bills, :bill_month_and_year, :string
    add_column :water_bills, :owner_amount, :decimal
    add_column :water_bills, :rent_amount, :decimal
  end
end
