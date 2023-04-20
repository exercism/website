require "test_helper"

class Webhooks::ProcessPaypalUpdateTest < ActiveSupport::TestCase
  [
    ["BILLING.SUBSCRIPTION.ACTIVATED", Donations::Paypal::Subscription::HandleActivated],
    ["BILLING.SUBSCRIPTION.CANCELLED", Donations::Paypal::Subscription::HandleCancelled],
    ["BILLING.SUBSCRIPTION.CREATED", Donations::Paypal::Subscription::HandleCreated],
    ["BILLING.SUBSCRIPTION.EXPIRED", Donations::Paypal::Subscription::HandleExpired],
    ["BILLING.SUBSCRIPTION.PAYMENT.FAILED", Donations::Paypal::Subscription::HandlePaymentFailed],
    ["BILLING.SUBSCRIPTION.RE-ACTIVATED", Donations::Paypal::Subscription::HandleReActivated],
    ["BILLING.SUBSCRIPTION.UPDATED", Donations::Paypal::Subscription::HandleUpdated],
    ["PAYMENT.SALE.COMPLETED", Donations::Paypal::Payment::HandleSaleCompleted],
    ["PAYMENT.SALE.DENIED", Donations::Paypal::Payment::HandleSaleDenied],
    ["PAYMENT.SALE.REFUNDED", Donations::Paypal::Payment::HandleSaleRefunded],
    ["PAYMENT.SALE.REVERSED", Donations::Paypal::Payment::HandleSaleReversed],
    ["PAYMENTS.PAYMENT.CREATED", Donations::Paypal::Payment::HandlePaymentCreated]
  ].each do |event_type, expected_command|
    test "process '#{event_type}' enqueues #{expected_command} job" do
      Webhooks::ProcessPaypalUpdate.(event_type, 8, { amount: 500 })

      assert_enqueued_with(job: MandateJob, args: [expected_command.name, 8, { amount: 500 }])
    end
  end

  ignored_event_types = ['CHECKOUT.ORDER.APPROVED', 'RISK.DISPUTE.CREATED', 'VAULT.CREDIT-CARD.CREATED']
  ignored_event_types.each do |invalid_event_type|
    test "should ignore '#{invalid_event_type}' event" do
      assert_no_enqueued_jobs do
        Webhooks::ProcessPaypalUpdate.(invalid_event_type, 8, {})
      end
    end
  end
end
