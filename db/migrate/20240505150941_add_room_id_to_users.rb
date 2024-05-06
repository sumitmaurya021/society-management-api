class AddRoomIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :room_id, :bigint, null: true
  end
end
