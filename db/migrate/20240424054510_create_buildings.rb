class CreateBuildings < ActiveRecord::Migration[7.1]
  def change
    create_table :buildings do |t|
      t.string :building_name
      t.string :building_address
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
