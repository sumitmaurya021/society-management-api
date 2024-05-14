class AddUserIdInPayment < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :user_id, :bigint, null: false
  end
end
