class AddIndexForNudgeJob < ActiveRecord::Migration[7.0]
  def change
    add_index :user_notifications, [:type, :user_id]
  end
end
