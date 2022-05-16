require 'test_helper'
require 'recursive-open-struct'

class Donations::TestBase < ActiveSupport::TestCase
  def mock_stripe_customer(id)
    RecursiveOpenStruct.new(
      id: id
    )
  end

  def mock_stripe_subscription(id, amount, status: 'active', item_id: SecureRandom.uuid, payment_intent: nil)
    data = RecursiveOpenStruct.new(
      id: id,
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
      status: status
    )

    if payment_intent
      data.latest_invoice = {
        payment_intent: payment_intent
      }
    end

    data
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

  def mock_stripe_invoice(id, subscription_id, status: 'open')
    OpenStruct.new(
      id: id,
      subscription: subscription_id,
      status: status
    )
  end

  def mock_stripe_payment_intent(id, invoice_id: nil, payment_method: nil)
    data = RecursiveOpenStruct.new(id: id)
    data.invoice = invoice_id if invoice_id
    data.payment_method = payment_method if payment_method
    data
  end
end
