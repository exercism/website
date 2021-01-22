class AddUuidToUserReputationTokens < ActiveRecord::Migration[6.1]
  def change
    add_column :user_reputation_tokens, :uuid, :string, null: true

    User::ReputationToken.find_each{ |t| t.update(uuid: SecureRandom.compact_uuid) }

    change_column_null :user_reputation_tokens, :uuid, false
  end
end
