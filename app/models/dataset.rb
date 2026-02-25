# == Schema Information
#
# Table name: datasets
#
#  id             :bigint           not null, primary key
#  concept_types  :text             is an Array
#  is_private     :boolean
#  link_to_self   :text
#  name           :text
#  namespace      :text
#  total_concepts :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  datagraphs_id  :text
#
class Dataset < ApplicationRecord
  def self.all_concept_types
    all.map(&:concept_types).flatten.uniq
  end

  def self.all_concept_type_routes
    all_concept_types.map { |concept_type| ConceptTypeRoute.new(concept_type) }
  end
end
