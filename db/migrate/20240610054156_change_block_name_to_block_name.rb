class ChangeBlockNameToBlockName < ActiveRecord::Migration[7.1]
  def change
    rename_column :blocks, :name, :block_name
    rename_column :floors, :number, :floor_number
  end
end
