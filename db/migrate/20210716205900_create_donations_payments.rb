class CreateDonationsPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :donations_payments do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :subscription, foreign_key: {to_table: :donations_subscriptions}
      t.string :stripe_id, null: false, index: {unique: true}
      t.string :stripe_receipt_url, null: false

      t.decimal :amount_in_cents, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
