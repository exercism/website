class AddSeenToReputation < ActiveRecord::Migration[6.1]
  def change
    add_column :user_reputation_tokens, :seen, :boolean, null: false, defualt: false
  end
end
