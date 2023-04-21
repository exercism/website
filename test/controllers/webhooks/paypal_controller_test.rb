require_relative './base_test_case'

class Webhooks::PaypalControllerTest < Webhooks::BaseTestCase
  test "create should return 403 when signature is invalid" do
    skip
    # TODO: enable once signature validation was added
    payload = {
      action: 'created',
      sponsorship: {
        sponsor: {
          login: 'user22'
        }
      }
    }

    invalid_headers = headers(payload)
    invalid_headers['HTTP_X_HUB_SIGNATURE_256'] = "invalid_signature"

    ProcessGithubSponsorUpdateJob.expects(:perform_later).never

    post webhooks_paypal_path, headers: invalid_headers, as: :json, params: payload
    assert_response :forbidden
  end

  test "create should return 200 when signature is valid" do
    payload = {
      event_type: "BILLING.SUBSCRIPTION.ACTIVATED",
      resource: {
        quantity: "20"
      }
    }

    Webhooks::ProcessPaypalUpdate.expects(:call).with(
      "BILLING.SUBSCRIPTION.ACTIVATED",
      { "quantity" => "20" }
    )

    post webhooks_paypal_path, headers: headers(payload), as: :json, params: payload
    assert_response :ok
  end
end
