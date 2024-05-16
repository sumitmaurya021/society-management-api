class ChangeUsersColumnsNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :block_id, true
    change_column_null :users, :floor_id, true
    change_column_null :users, :room_number, true
  end
end
