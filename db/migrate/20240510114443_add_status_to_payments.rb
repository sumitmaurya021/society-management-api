class AddStatusToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :status, :integer
  end
end
