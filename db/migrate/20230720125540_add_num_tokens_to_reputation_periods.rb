class AddNumTokensToReputationPeriods < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_reputation_periods, :num_tokens, :integer, null: false, default: 0
  end
end
