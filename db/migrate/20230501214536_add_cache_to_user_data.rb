class AddCacheToUserData < ActiveRecord::Migration[7.0]
  def change
    # This needs to be in both fields for now.
    # It will need removing from `users`
    add_column :user, :cache, :json, null: true
    add_column :user_data, :cache, :json, null: true
  end
end
