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
      resource = { amount: 500 }
      expected_command.expects(:call).with(resource)

      Webhooks::ProcessPaypalUpdate.(event_type, resource)
    end
  end

  ignored_event_types = ['CHECKOUT.ORDER.APPROVED', 'RISK.DISPUTE.CREATED', 'VAULT.CREDIT-CARD.CREATED']
  ignored_event_types.each do |invalid_event_type|
    test "should ignore '#{invalid_event_type}' event" do
      Donations::Paypal::Subscription::HandleActivated.expects(:call).never
      Donations::Paypal::Subscription::HandleCancelled.expects(:call).never
      Donations::Paypal::Subscription::HandleCreated.expects(:call).never
      Donations::Paypal::Subscription::HandleExpired.expects(:call).never
      Donations::Paypal::Subscription::HandlePaymentFailed.expects(:call).never
      Donations::Paypal::Subscription::HandleReActivated.expects(:call).never
      Donations::Paypal::Subscription::HandleUpdated.expects(:call).never
      Donations::Paypal::Payment::HandleSaleCompleted.expects(:call).never
      Donations::Paypal::Payment::HandleSaleDenied.expects(:call).never
      Donations::Paypal::Payment::HandleSaleRefunded.expects(:call).never
      Donations::Paypal::Payment::HandleSaleReversed.expects(:call).never
      Donations::Paypal::Payment::HandlePaymentCreated.expects(:call).never

      Webhooks::ProcessPaypalUpdate.(invalid_event_type, {})
    end
  end
end
