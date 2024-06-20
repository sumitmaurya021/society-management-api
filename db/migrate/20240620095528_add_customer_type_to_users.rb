class AddCustomerTypeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :customer_type, :string
  end
end
