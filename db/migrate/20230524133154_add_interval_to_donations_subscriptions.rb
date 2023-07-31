class AddIntervalToDonationsSubscriptions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :donations_subscriptions, :interval, :tinyint, null: false, default: 0
  end
end
