class AddIndexForNudgeJob < ActiveRecord::Migration[6.1]
  def change
    add_index :solutions, [:last_iterated_at, :user_id], name: "fast_1"
    add_index :solutions, [:user_id, :last_iterated_at], name: "fast_2"
    add_index :solutions, [:type, :user_id, :exercise_id, :last_iterated_at], name: "fast_3"
    add_index :solutions, [:exercise_id, :type, :user_id, :last_iterated_at], name: "fast_4"
    add_index :user_notifications, [:type], name: "fast_5"
    add_index :user_notifications, [:user_id, :type], name: "fast_7"

    # Definites
    add_index :user_notifications, [:type, :user_id], name: "fast_6"
  end
end
