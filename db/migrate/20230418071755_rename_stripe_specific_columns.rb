class RenameStripeSpecificColumns < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    rename_column :donations_subscriptions, :stripe_id, :external_id
    rename_column :donations_payments, :stripe_id, :external_id
    rename_column :donations_payments, :stripe_receipt_url, :external_receipt_url
  end
end
