class AddLateFeeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :owner_amount, :decimal, precision: 10, scale: 2
    add_column :users, :rent_amount, :decimal, precision: 10, scale: 2
  end
end
