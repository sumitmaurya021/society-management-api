class RemovePaymentStatusinPayments < ActiveRecord::Migration[7.1]
  def change
    remove_column :payments, :payment_status
  end
end
