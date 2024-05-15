class AddTotalUnitsInRoom < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :total_units, :integer
  end
end
