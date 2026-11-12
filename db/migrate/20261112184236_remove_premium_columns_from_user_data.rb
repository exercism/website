class RemovePremiumColumnsFromUserData < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    remove_index :user_data, :premium_until, if_exists: true
    remove_column :user_data, :premium_until, :datetime, null: true
    remove_column :user_data, :usages, :json
  end
end
