class RefactorReputationTokens < ActiveRecord::Migration[6.1]
  def change
    User::ReputationToken.destroy_all
    add_column :user_reputation_tokens, :level, :string, null: true

    add_column :user_reputation_tokens, :params, :json, null: false
    add_column :user_reputation_tokens, :type, :string, null: false
    add_column :user_reputation_tokens, :version, :integer, null: false
    add_column :user_reputation_tokens, :rendering_data_cache, :json, null: false

    rename_column :user_reputation_tokens, :context_key, :uniqueness_key

    remove_column :user_reputation_tokens, :context_type
    remove_column :user_reputation_tokens, :context_id
  end
end
