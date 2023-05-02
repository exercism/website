class AddCacheToUserData < ActiveRecord::Migration[7.0]
  def change
    add_column :user_data, :cache, :json, null: true
  end
end
