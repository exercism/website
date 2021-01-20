class AddExerciseToReputationTokens < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :user_reputation_tokens, :exercise, foreign_key: true, null: true
  end
end
