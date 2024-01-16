require "test_helper"

class Webhooks::ProcessPaypalIPNTest < ActiveSupport::TestCase
  [
    ["web_accept", Payments::Paypal::Payment::IPN::HandleWebAccept],
    ["recurring_payment", Payments::Paypal::Subscription::IPN::HandleRecurringPayment],
    ["recurring_payment_expired", Payments::Paypal::Subscription::IPN::HandleRecurringPaymentExpired],
    ["recurring_payment_failed", Payments::Paypal::Subscription::IPN::HandleRecurringPaymentFailed],
    ["recurring_payment_profile_cancel", Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCancel],
    ["recurring_payment_skipped", Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSkipped],
    ["recurring_payment_suspended", Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSuspended],
    ["recurring_payment_suspended_due_to_max_failed_payment",
     Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSuspendedDueToMaxFailedPayment]
  ].each do |(txn_type, expected_command)|
    test "handle IPN event with txn_type #{txn_type}" do
      txn_id = SecureRandom.uuid
      payload = "txn_id=#{txn_id}&txn_type=#{txn_type}"

      stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
        to_return(status: 200, body: "VERIFIED", headers: {})

      expected_command.expects(:call).with({
        "txn_id" => txn_id,
        "txn_type" => txn_type
      })

      Webhooks::ProcessPaypalIPN.(payload)
    end
  end

  %w[
    adjustment cart express_checkout masspay merch_pmt mp_cancel new_case
  ].each do |txn_type|
    test "ignore IPN event with txn_type #{txn_type}" do
      txn_id = SecureRandom.uuid
      payload = "txn_id=#{txn_id}&txn_type=#{txn_type}"

      stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
        to_return(status: 200, body: "VERIFIED", headers: {})

      Payments::Paypal::Payment::IPN::HandleWebAccept.expects(:call).never
      Payments::Paypal::Subscription::IPN::HandleRecurringPayment.expects(:call).never
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentExpired.expects(:call).never
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentFailed.expects(:call).never
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCancel.expects(:call).never
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSkipped.expects(:call).never
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSuspended.expects(:call).never
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSuspendedDueToMaxFailedPayment.expects(:call).never

      Webhooks::ProcessPaypalIPN.(payload)
    end
  end

  test "bugsnag is created if IPN is invalid" do
    payload = "txn_id=#{SecureRandom.uuid}&txn_type=web_accept"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      to_return(status: 200, body: "INVALID", headers: {})

    Bugsnag.expects(:notify).once

    Webhooks::ProcessPaypalIPN.(payload)
  end

  test "bugsnag is created if IPN verification has unknown result" do
    payload = "txn_id=#{SecureRandom.uuid}&txn_type=web_accept"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      to_return(status: 200, body: "UNKNOWN", headers: {})

    Bugsnag.expects(:notify).once

    Webhooks::ProcessPaypalIPN.(payload)
  end

  test "bugsnag is created if error occurs in verification request" do
    payload = "txn_id=#{SecureRandom.uuid}&txn_type=web_accept"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      to_return(status: 500, body: "ERROR", headers: {})

    Bugsnag.expects(:notify).once

    Webhooks::ProcessPaypalIPN.(payload)
  end
end
