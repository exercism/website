class AddDiscordIdToUsers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :users, :discord_uid, :string, null: true
    add_index :users, :discord_uid, unique: true
  end
end
