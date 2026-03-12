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
class Publication < Concept
  store_accessor :properties, :title, :synopsis, :publishedAt, :publishedBy, :createdAt

  def published_at
    publishedAt
  end

  def published_by
    publishedBy
  end

  def created_at
    createdAt
  end
end

