class AddStatusToDonationsSubscriptions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    unless column_exists?(:donations_subscriptions, :status)
    add_column :donations_subscriptions, :status, :tinyint, null: false, default: 0

    Donations::Subscription.where(active: true).update_all(status: :active)
    Donations::Subscription.where(active: false).update_all(status: :canceled)
    end
  end
end
