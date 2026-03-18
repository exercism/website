class AddShadowBannedToUsers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :users, :shadow_banned_at, :datetime, null: true
    add_column :users, :shadow_banned_by_id, :bigint, null: true
    add_foreign_key :users, :users, column: :shadow_banned_by_id
  end
end
