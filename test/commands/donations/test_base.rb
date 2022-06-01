require 'test_helper'
require 'recursive-open-struct'

class Donations::TestBase < ActiveSupport::TestCase
  def mock_stripe_customer(id)
    RecursiveOpenStruct.new(
      id:
    )
  end

  def mock_stripe_subscription(id, amount, status: 'active', item_id: SecureRandom.uuid, payment_intent: nil)
    data = RecursiveOpenStruct.new(
      id:,
      items: {
        data: [
          RecursiveOpenStruct.new(
            id: item_id,
            price: {
              unit_amount: amount
            }
          )
        ]
      },
      status:
    )

    if payment_intent
      data.latest_invoice = {
        payment_intent:
      }
    end

    data
  end

  def mock_stripe_payment(id, amount, receipt_url, invoice_id: nil)
    OpenStruct.new(
      id:,
      amount:,
      invoice: invoice_id,
      charges: [
        OpenStruct.new(receipt_url:)
      ]
    )
  end

  def mock_stripe_invoice(id, subscription_id, status: 'open')
    OpenStruct.new(
      id:,
      subscription: subscription_id,
      status:
    )
  end

  def mock_stripe_payment_intent(id, invoice_id: nil, payment_method: nil)
    data = RecursiveOpenStruct.new(id:)
    data.invoice = invoice_id if invoice_id
    data.payment_method = payment_method if payment_method
    data
  end
end
