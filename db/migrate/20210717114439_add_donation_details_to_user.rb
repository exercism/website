class AddDonationDetailsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :total_donated_in_cents, :integer, null: true, default: 0
    add_column :users, :active_subscription, :boolean, null: true, default: false
  end
end
