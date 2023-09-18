class AddInsidersStatusToUsers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :users, :insiders_status, :tinyint, null: false, default: 0
    add_index :users, :insiders_status
  end
end
