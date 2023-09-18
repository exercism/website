class AddProviderToDonationsPayments < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :donations_payments, :provider, :tinyint, null: false, default: 0

    Donations::Payment.update_all(provider: :stripe)

    remove_index :donations_payments, :stripe_id
    add_index :donations_payments, [:stripe_id, :provider], unique: true, if_not_exists: true
  end
end
