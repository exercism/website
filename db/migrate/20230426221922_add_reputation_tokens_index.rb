class AddReputationTokensIndex < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :user_reputation_tokens, [:user_id, :category]

    remove_index :user_reputation_tokens, name: :index_user_reputation_tokens_on_track_id
  end
end
