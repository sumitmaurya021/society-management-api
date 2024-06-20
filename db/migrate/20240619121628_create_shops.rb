class CreateShops < ActiveRecord::Migration[7.1]
  def change
    create_table :shops do |t|
      t.string :shop_name
      t.references :block, null: false, foreign_key: true
      t.references :floor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
