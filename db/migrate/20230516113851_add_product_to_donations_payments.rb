class AddProductToDonationsPayments < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :donations_payments, :product, :tinyint, null: false, default: 0

    Payments::Payment.update_all(product: :donation)
  end
end
