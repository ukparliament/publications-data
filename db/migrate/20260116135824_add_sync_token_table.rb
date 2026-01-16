class AddSyncTokenTable < ActiveRecord::Migration[8.1]
  def change
    create_table :oauth_access_tokens do |t|
      t.text        :token
      t.datetime    :expires_in
      t.timestamps
    end
  end
end
