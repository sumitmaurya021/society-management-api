class AddUnitRateToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :unit_rate, :float
    add_column :rooms, :previous_unit, :float
    add_column :rooms, :updated_unit, :float
  end
end
