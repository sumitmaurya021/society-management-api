class AddGenterToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :gender, :string
  end
end
