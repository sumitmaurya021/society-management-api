class DeleteColumnYournameNameAmountFromMaintenenceBills < ActiveRecord::Migration[7.1]
  def change
    remove_column :maintenance_bills, :your_name
    remove_column :maintenance_bills, :name
    remove_column :maintenance_bills, :amount
  end
end
