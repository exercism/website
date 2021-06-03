class AddUuidIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :user_reputation_tokens, :uuid, unique: true
  end
end
