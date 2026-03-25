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
class PublicationExpression < Concept
  store_accessor :properties, :title, :number, :createdAt, :updatedAt, :teaserText, :publishedAt, :expressionOf, :hasPublicationExpressionStatus

  def created_at
    createdAt
  end

  def display_created_at
    return "" unless created_at

    Time.zone.parse(created_at).strftime("%d/%m/%Y %H:%M")
  end

  def updated_at
    updatedAt
  end

  def teaser_text
    teaserText
  end

  def published_at
    publishedAt
  end

  def display_published_at
    return "" unless published_at

    Time.zone.parse(published_at).strftime("%d/%m/%Y %H:%M")
  end

  def expression_of
    expressionOf
  end

  def has_publication_expression_status
    hasPublicationExpressionStatus
  end

  def contributions
    Contribution.where("properties->>'contributionTo' = ?", datagraphs_id)
  end

  def status
    PublicationExpressionStatus.labels[has_publication_expression_status]
  end

end

