class AddCurrentUnitToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :current_unit, :float
  end
end
