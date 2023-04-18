class AddProviderToDonationsPayments < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :donations_payments, :provider, :tinyint, null: false, default: 0

    Donations::Payment.update_all(provider: :stripe)
  end
end
