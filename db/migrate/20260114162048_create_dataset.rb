class CreateDataset < ActiveRecord::Migration[8.1]
  def change
    create_table :datasets do |t|
      t.text        :link_to_self
      t.text        :name
      t.text        :namespace
      t.boolean     :is_private
      t.text        :datagraphs_id
      t.integer     :total_concepts
      t.text        :concept_types, array: true
      t.timestamps
    end
  end
end
