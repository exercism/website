class AddProductToDonationsSubscriptions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :donations_subscriptions, :product, :tinyint, null: false, default: 0

    Payments::Subscription.update_all(product: :donation)
  end
end
