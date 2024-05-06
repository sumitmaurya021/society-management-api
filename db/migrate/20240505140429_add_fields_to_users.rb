class AddFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :mobile_number, :string
    add_reference :users, :block, null: false, foreign_key: true
    add_reference :users, :floor, null: false, foreign_key: true
    add_column :users, :room_number, :integer, default: 0
    add_column :users, :owner_or_renter, :integer, default: 0
  end
end
