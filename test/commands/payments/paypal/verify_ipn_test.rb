require_relative '../test_base'

class Payments::Paypal::VerifyIPNTest < Payments::TestBase
  test "does not raise when response indicates IPN was valid" do
    payload = "txn_type=recurring_payment"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      with(body: "cmd=_notify-validate&#{payload}").
      to_return(status: 200, body: "VERIFIED", headers: {})

    Payments::Paypal::VerifyIPN.(payload)

    # If an error was raised, we'd have a failing test
  end

  test "raises when response indicates IPN was invalid" do
    payload = "txn_type=recurring_payment"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      with(body: "cmd=_notify-validate&#{payload}").
      to_return(status: 200, body: "INVALID", headers: {})

    assert_raises Payments::Paypal::InvalidIPNError do
      Payments::Paypal::VerifyIPN.(payload)
    end
  end

  test "raises when response is unknown" do
    payload = "txn_type=recurring_payment"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      with(body: "cmd=_notify-validate&#{payload}").
      to_return(status: 200, body: "UNKNOWN", headers: {})

    assert_raises Payments::Paypal::IPNVerificationError do
      Payments::Paypal::VerifyIPN.(payload)
    end
  end

  test "raises when response was erronous" do
    payload = "txn_type=recurring_payment"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      with(body: "cmd=_notify-validate&#{payload}").
      to_return(status: 400, body: "", headers: {})

    assert_raises Payments::Paypal::IPNVerificationError do
      Payments::Paypal::VerifyIPN.(payload)
    end
  end
end
