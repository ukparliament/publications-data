# == Schema Information
#
# Table name: oauth_access_tokens
#
#  id         :bigint           not null, primary key
#  expires_in :datetime
#  token      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class OAuthAccessToken < ApplicationRecord
  self.table_name = "oauth_access_tokens"
end
