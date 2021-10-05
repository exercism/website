class AddEmailToDonations < ActiveRecord::Migration[6.1]
  def change
    add_column :donations_payments, :email_status, :integer, limit: 1, default: 0, null: false
    add_column :donations_subscriptions, :email_status, :integer, limit: 1, default: 0, null: false
  end
end
