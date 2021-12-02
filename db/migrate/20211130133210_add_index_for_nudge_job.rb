class AddIndexForNudgeJob < ActiveRecord::Migration[6.1]
  def change
    add_index :user_notifications, [:type, :user_id]
  end
end
