class AddEmailStatusToUserData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_data, :email_status, :tinyint, null: false, default: 0
  end
end
