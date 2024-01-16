class AddIndexOnUsersCreatedAt < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    add_index :users, :created_at
  end
end
