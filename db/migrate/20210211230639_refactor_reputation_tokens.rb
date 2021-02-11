class RefactorReputationTokens < ActiveRecord::Migration[6.1]
  def change
    User::ReputationToken.destroy_all
    add_column :user_reputation_tokens, :params, :json, null: false
    rename_column :user_reputation_tokens, :context_key, :uniqueness_key
    add_column :user_reputation_tokens, :type, :string, null: false
    add_column :user_reputation_tokens, :version, :integer, null: false
  end
end
