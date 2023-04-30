class RemoveActiveFromSubscriptions < ActiveRecord::Migration[7.0]
  def change
    remove_column :donations_subscriptions, :active
  end
end
