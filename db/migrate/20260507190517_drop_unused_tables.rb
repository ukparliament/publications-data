class DropUnusedTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :concepts
    drop_table :datasets
  end
end
