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
class Concept < ApplicationRecord
end
