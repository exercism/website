class LimitOneProfilePerUser < ActiveRecord::Migration[6.1]
  def change
    add_index :user_profiles, :user_id, unique: true
    add_foreign_key :user_profiles, :users
  end
end
