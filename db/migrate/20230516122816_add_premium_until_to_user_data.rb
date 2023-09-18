class AddPremiumUntilToUserData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_data, :premium_until, :datetime, null: true
    add_index :user_data, :premium_until, if_not_exists: true
  end
end
