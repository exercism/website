require 'test_helper'
require 'recursive-open-struct'

class Donations::TestBase < ActiveSupport::TestCase
  def mock_stripe_customer(id)
    RecursiveOpenStruct.new(
      id: id
    )
  end

  def mock_stripe_subscription(id, amount)
    RecursiveOpenStruct.new(
      id: id,
      plan: { amount: amount }
    )
  end

  def mock_stripe_payment(id, amount, receipt_url, invoice_id: nil)
    OpenStruct.new(
      id: id,
      amount: amount,
      invoice: invoice_id,
      charges: [
        OpenStruct.new(receipt_url: receipt_url)
      ]
    )
  end

  def mock_stripe_invoice(subscription_id)
    OpenStruct.new(
      subscription: subscription_id
    )
  end
end
