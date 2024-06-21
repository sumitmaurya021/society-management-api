class AddShopNumberToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :shop_number, :string
  end
end
