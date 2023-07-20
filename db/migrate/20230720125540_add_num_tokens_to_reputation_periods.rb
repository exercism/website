class AddNumTokensToReputationPeriods < ActiveRecord::Migration[7.0]
  def change
    add_column :user_reputation_periods, :num_tokens, :integer, null: false, default: 0
  end
end
