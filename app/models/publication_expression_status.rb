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
class PublicationExpressionStatus < Concept
  # This is just a look up with the label being the value
  def self.labels
    @labels ||= load_labels
  end

  private

  def self.load_labels
    pluck(:datagraphs_id, :label).to_h
  end

  # def self.load_labels_with_int_keys
  #   pluck(:datagraphs_id, :label).to_h { |datagraphs_id, label| [convert_to_integer_from_datagraphs_id(datagraphs_id), label] }
  # end

  # def self.convert_to_integer_from_datagraphs_id(datagraphs_id)
  #   datagraphs_id.split(':')[-1].to_i
  # end
end
