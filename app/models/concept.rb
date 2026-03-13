# == Schema Information
#
# Table name: concepts
#
#  id              :bigint           not null, primary key
#  datagraphs_type :text
#  label           :text
#  properties      :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  datagraphs_id   :text
#
# Indexes
#
#  index_concepts_on_datagraphs_id  (datagraphs_id)
#
class Concept < ApplicationRecord
  store_accessor :properties,  :title, :name

  self.inheritance_column = "datagraphs_type"

  def display_title
    name || title || label
  end

  # def self.jsonb_join(target_type, jsonb_key, local_key: :id)
  #   target = Concept.arel_table.alias("#{target_type.underscore}_nodes")

  #   joins(
  #     arel_table.join(target).on(
  #       Arel::Nodes::SqlLiteral.new(
  #         "(#{target.name}.properties->>'#{jsonb_key}')::integer = #{arel_table.name}.#{local_key}
  #          AND #{target.name}.type = '#{target_type}'"
  #       )
  #     ).join_sources
  #   )
  # end

end
