class AddPaypalPayerIdToUsers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :users, :paypal_payer_id, :string, null: true
    add_index :users, :paypal_payer_id, unique: true
  end
end
