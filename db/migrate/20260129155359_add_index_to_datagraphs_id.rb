class AddIndexToDatagraphsId < ActiveRecord::Migration[8.1]
  def change
    add_index :concepts, :datagraphs_id
  end
end
