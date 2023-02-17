class AddIndexOnUsersCreatedAt < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_index :users, :created_at
    end
  end
end
