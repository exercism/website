class AddIndexOnUserIdAndSeenToUserReputationTokens < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :user_reputation_tokens, %i[user_id seen]
    remove_index :user_reputation_tokens, :user_id
  end
end
