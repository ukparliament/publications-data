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
class Contribution < Concept
  store_accessor :properties, :isPublic, :ordinality, :contributionBy, :contributionTo, :hasContributionType

  scope :with_publication_expression, -> {
    joins(
      "INNER JOIN concepts AS c
       ON c.datagraphs_id::text = (concepts.properties->>'contributionTo')
       AND c.datagraphs_type = 'PublicationExpression'"
    ).select("concepts.*, c.properties AS pub_expr_properties")
  }

  def publication_expression
    PublicationExpression.find_by(datagraphs_id: contribution_to)
  end

  def person
    Person.find_by(datagraphs_id: contribution_by)
  end

  def is_public?
    isPublic
  end

  def contribution_by
    contributionBy
  end

  def contribution_to
    contributionTo
  end

  def has_contribution_type
    hasContributionType
  end
end
