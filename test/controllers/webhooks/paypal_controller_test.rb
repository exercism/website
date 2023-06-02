require_relative './base_test_case'

class Webhooks::PaypalControllerTest < Webhooks::BaseTestCase
  test "create should return 200" do
    post webhooks_paypal_path, as: :json
    assert_response :ok
  end

  test "create should process IPN event payload" do
    payload = {
      ipn_track_id: SecureRandom.compact_uuid,
      txn_type: "web_accept"
    }

    Webhooks::ProcessPaypalIpnUpdate.expects(:defer).with(payload.to_json)

    post webhooks_paypal_path, headers: headers(payload), as: :json, params: payload
  end

  test "create should process API event payload" do
    payload = {
      event_type: "BILLING.SUBSCRIPTION.ACTIVATED",
      resource: {
        quantity: "20"
      }
    }

    Webhooks::ProcessPaypalIpnUpdate.expects(:defer).never

    post webhooks_paypal_path, headers: headers(payload), as: :json, params: payload
  end
end
