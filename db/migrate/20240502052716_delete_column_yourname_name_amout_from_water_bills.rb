class DeleteColumnYournameNameAmoutFromWaterBills < ActiveRecord::Migration[7.1]
  def change
    remove_column :water_bills, :your_name
    remove_column :water_bills, :name
    remove_column :water_bills, :amount
  end
end
