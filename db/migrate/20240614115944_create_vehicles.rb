class CreateVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicles do |t|
      t.integer :total_no_of_two_wheeler
      t.integer :total_no_of_four_wheeler
      t.text :two_wheeler_numbers, array: true, default: []
      t.text :four_wheeler_numbers, array: true, default: []
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
