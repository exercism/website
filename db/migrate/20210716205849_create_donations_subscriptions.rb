class CreateDonationsSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :donations_subscriptions do |t|
      t.belongs_to :user, foreign_key: true,  null: false
      t.string :stripe_id, null: false, index: {unique: true}

      t.boolean :active, default: true, null: false
      t.decimal :amount_in_cents, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
