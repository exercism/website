require_relative '../test_base'

class Payments::Paypal::VerifyAPIEventTest < Payments::TestBase
  test "does not raise when response indicates API event was valid" do
    event = { "id" => SecureRandom.compact_uuid }
    headers = {
      'PAYPAL-TRANSMISSION-ID' => SecureRandom.compact_uuid,
      'PAYPAL-TRANSMISSION-TIME' => SecureRandom.compact_uuid,
      'PAYPAL-CERT-URL' => SecureRandom.compact_uuid,
      'PAYPAL-AUTH-ALGO' => SecureRandom.compact_uuid,
      'PAYPAL-TRANSMISSION-SIG' => SecureRandom.compact_uuid
    }
    access_token = SecureRandom.compact_uuid

    Payments::Paypal::RequestAccessToken.stubs(:call).returns(access_token)

    stub_request(:post, "https://api-m.sandbox.paypal.com/v1/notifications/verify-webhook-signature").
      with(
        body:
        {
          transmission_id: headers['PAYPAL-TRANSMISSION-ID'],
          transmission_time: headers['PAYPAL-TRANSMISSION-TIME'],
          cert_url: headers['PAYPAL-CERT-URL'],
          auth_algo: headers['PAYPAL-AUTH-ALGO'],
          transmission_sig: headers['PAYPAL-TRANSMISSION-SIG'],
          webhook_id: Exercism.secrets.paypal_webhook_id,
          webhook_event: event
        },
        headers: {
          'Authorization' => "Bearer #{access_token}",
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: { verification_status: 'SUCCESS' }.to_json, headers: { 'Content-Type' => 'application/json' })

    Payments::Paypal::VerifyAPIEvent.(event, headers)

    # If an error was raised, we'd have a failing test
  end

  test "raises when response verification status indicates API event failed verification" do
    event = { "id" => SecureRandom.compact_uuid }
    headers = {
      'PAYPAL-TRANSMISSION-ID' => SecureRandom.compact_uuid,
      'PAYPAL-TRANSMISSION-TIME' => SecureRandom.compact_uuid,
      'PAYPAL-CERT-URL' => SecureRandom.compact_uuid,
      'PAYPAL-AUTH-ALGO' => SecureRandom.compact_uuid,
      'PAYPAL-TRANSMISSION-SIG' => SecureRandom.compact_uuid
    }
    access_token = SecureRandom.compact_uuid

    Payments::Paypal::RequestAccessToken.stubs(:call).returns(access_token)

    stub_request(:post, "https://api-m.sandbox.paypal.com/v1/notifications/verify-webhook-signature").
      with(
        body:
        {
          transmission_id: headers['PAYPAL-TRANSMISSION-ID'],
          transmission_time: headers['PAYPAL-TRANSMISSION-TIME'],
          cert_url: headers['PAYPAL-CERT-URL'],
          auth_algo: headers['PAYPAL-AUTH-ALGO'],
          transmission_sig: headers['PAYPAL-TRANSMISSION-SIG'],
          webhook_id: Exercism.secrets.paypal_webhook_id,
          webhook_event: event
        },
        headers: {
          'Authorization' => "Bearer #{access_token}",
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: { verification_status: 'FAILURE' }.to_json, headers: { 'Content-Type' => 'application/json' })

    assert_raises Payments::Paypal::InvalidAPIEventError do
      Payments::Paypal::VerifyAPIEvent.(event, headers)
    end
  end

  test "raises when response verification status is unknown" do
    event = { "id" => SecureRandom.compact_uuid }
    headers = {
      'PAYPAL-TRANSMISSION-ID' => SecureRandom.compact_uuid,
      'PAYPAL-TRANSMISSION-TIME' => SecureRandom.compact_uuid,
      'PAYPAL-CERT-URL' => SecureRandom.compact_uuid,
      'PAYPAL-AUTH-ALGO' => SecureRandom.compact_uuid,
      'PAYPAL-TRANSMISSION-SIG' => SecureRandom.compact_uuid
    }
    access_token = SecureRandom.compact_uuid

    Payments::Paypal::RequestAccessToken.stubs(:call).returns(access_token)

    stub_request(:post, "https://api-m.sandbox.paypal.com/v1/notifications/verify-webhook-signature").
      with(
        body:
        {
          transmission_id: headers['PAYPAL-TRANSMISSION-ID'],
          transmission_time: headers['PAYPAL-TRANSMISSION-TIME'],
          cert_url: headers['PAYPAL-CERT-URL'],
          auth_algo: headers['PAYPAL-AUTH-ALGO'],
          transmission_sig: headers['PAYPAL-TRANSMISSION-SIG'],
          webhook_id: Exercism.secrets.paypal_webhook_id,
          webhook_event: event
        },
        headers: {
          'Authorization' => "Bearer #{access_token}",
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: { verification_status: 'UNKNOWN' }.to_json, headers: { 'Content-Type' => 'application/json' })

    assert_raises Payments::Paypal::APIEventVerificationError do
      Payments::Paypal::VerifyAPIEvent.(event, headers)
    end
  end

  test "raises when response was erronous" do
    event = {}
    headers = {}

    Payments::Paypal::RequestAccessToken.stubs(:call).returns(SecureRandom.compact_uuid)

    stub_request(:post, "https://api-m.sandbox.paypal.com/v1/notifications/verify-webhook-signature").
      to_return(status: 400, body: "", headers: {})

    assert_raises Payments::Paypal::APIEventVerificationError do
      Payments::Paypal::VerifyAPIEvent.(event, headers)
    end
  end
end
