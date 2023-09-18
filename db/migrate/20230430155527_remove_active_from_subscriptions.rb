class RemoveActiveFromSubscriptions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    remove_column :donations_subscriptions, :active
  end
end
