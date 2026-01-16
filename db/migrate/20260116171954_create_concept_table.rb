class CreateConceptTable < ActiveRecord::Migration[8.1]
  def change
    create_table :concepts do |t|
      t.text        :datagraphs_id
      t.text        :datagraphs_type
      t.text        :label
      t.jsonb       :properties
      t.timestamps
    end
  end
end
