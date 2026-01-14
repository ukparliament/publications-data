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
end
