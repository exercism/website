class AddReputationTokenContextKey < ActiveRecord::Migration[6.1]
  def change
    add_column :user_reputation_tokens, :context_key, :string, null: false
    add_index :user_reputation_tokens, %i[context_key user_id], unique: true
  end
end
