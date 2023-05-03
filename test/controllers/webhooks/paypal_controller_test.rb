require_relative './base_test_case'

class Webhooks::PaypalControllerTest < Webhooks::BaseTestCase
  test "create should return 403 when signature is invalid" do
    payload = {
      event_type: "BILLING.SUBSCRIPTION.ACTIVATED",
      resource: {
        quantity: "20"
      }
    }

    Webhooks::Paypal::VerifySignature.expects(:call).raises(Webhooks::Paypal::VerifySignature::SignatureVerificationError)

    post webhooks_paypal_path, as: :json, params: payload
    assert_response :forbidden
  end

  test "create should return 200 when signature is valid" do
    payload = {
      event_type: "BILLING.SUBSCRIPTION.ACTIVATED",
      resource: {
        quantity: "20"
      }
    }

    Webhooks::Paypal::VerifySignature.stubs(:call)

    Webhooks::ProcessPaypalUpdate.expects(:call).with(
      "BILLING.SUBSCRIPTION.ACTIVATED",
      { "quantity" => "20" }
    )

    post webhooks_paypal_path, headers: headers(payload), as: :json, params: payload
    assert_response :ok
  end
end
