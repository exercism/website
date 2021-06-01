class AddEarnedAtToReputationTokens < ActiveRecord::Migration[6.1]
  def change
    add_column :user_reputation_tokens, :earned_on, :date, null: true
    User::ReputationToken.update_all('earned_on = created_at')
    change_column_null :user_reputation_tokens, :earned_on, :false

    add_index :user_reputation_tokens, :earned_on, name: "sweeper"
  end
end
