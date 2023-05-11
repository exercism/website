require "test_helper"

class Webhooks::ProcessPaypalUpdateTest < ActiveSupport::TestCase
  test "bugsnag is created when IPN is invalid" do
    payload = "txn_id=5E125564UE4492634&txn_type=web_accept"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      to_return(status: 200, body: "INVALID", headers: {})

    Bugsnag.expects(:notify).once

    Webhooks::ProcessPaypalUpdate.(payload)
  end

  test "bugsnag is created when IPN verification has unknown result" do
    payload = "txn_id=5E125564UE4492634&txn_type=web_accept"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      to_return(status: 200, body: "UNKNOWN", headers: {})

    Bugsnag.expects(:notify).once

    Webhooks::ProcessPaypalUpdate.(payload)
  end

  test "bugsnag is created when error occurs in verification request" do
    payload = "txn_id=5E125564UE4492634&txn_type=web_accept"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      to_return(status: 500, body: "ERROR", headers: {})

    Bugsnag.expects(:notify).once

    Webhooks::ProcessPaypalUpdate.(payload)
  end
end
