class ChangeExternalReceiptUrlToNullInDonationsPayments < ActiveRecord::Migration[7.0]
  def change
    change_column_null :donations_payments, :external_receipt_url, true
  end
end
