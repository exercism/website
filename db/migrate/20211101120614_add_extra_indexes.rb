class AddExtraIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :unconfirmed_email, if_not_exists: true

    add_index :user_reputation_tokens, [:user_id, :type], name: 'index_user_reputation_tokens_query_1', if_not_exists: true
    add_index :user_reputation_tokens, [:user_id, :track_id, :type], name: 'index_user_reputation_tokens_query_2', if_not_exists: true
    add_index :user_reputation_tokens, [:user_id, :earned_on, :type], name: 'index_user_reputation_tokens_query_3', if_not_exists: true
    add_index :user_reputation_tokens, [:user_id, :track_id, :earned_on, :type], name: 'index_user_reputation_tokens_query_4', if_not_exists: true

    add_index :mentor_requests, :uuid, name: 'index_mentor_requests_on_uuid', unique: true, if_not_exists: true

    add_foreign_key :solution_comments, :solutions unless foreign_key_exists?(:solution_comments, :solutions)
  end
end
