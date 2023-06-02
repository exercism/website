require_relative './base_test_case'

class Webhooks::PaypalControllerTest < Webhooks::BaseTestCase
  test "create should return 200" do
    post webhooks_paypal_path, as: :json
    assert_response :ok
  end

  test "create should process webhook event payload" do
    payload = {
      event_type: "BILLING.SUBSCRIPTION.ACTIVATED",
      resource: {
        quantity: "20"
      }
    }
    paypal_headers = {
      'PAYPAL-AUTH-ALGO' => SecureRandom.compact_uuid,
      'PAYPAL-CERT-URL' => SecureRandom.compact_uuid,
      'PAYPAL-TRANSMISSION-ID' => SecureRandom.compact_uuid,
      'PAYPAL-TRANSMISSION-SIG' => SecureRandom.compact_uuid,
      'PAYPAL-TRANSMISSION-TIME' => SecureRandom.compact_uuid
    }
    headers = paypal_headers.merge({ 'CONTENT_TYPE' => 'application/json' })

    Webhooks::ProcessPaypalAPIEvent.expects(:defer).with(payload.to_json, paypal_headers)

    post webhooks_paypal_path, headers:, as: :json, params: payload
  end

  test "ipn should return 200" do
    post ipn_webhooks_paypal_path, as: :json
    assert_response :ok
  end

  test "ipn should process IPN event payload" do
    payload = {
      ipn_track_id: SecureRandom.compact_uuid,
      txn_type: "web_accept"
    }

    Webhooks::ProcessPaypalIPN.expects(:defer).with(payload.to_json)

    post ipn_webhooks_paypal_path, headers: headers(payload), as: :json, params: payload
  end
end
