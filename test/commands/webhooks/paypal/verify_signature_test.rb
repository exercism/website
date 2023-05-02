require "test_helper"

class Webhooks::Paypal::VerifySignatureTest < ActiveSupport::TestCase
  test "does not raise when signature is valid" do
    stub_request(:post, "https://api-m.paypal.com/v1/notifications/verify-webhook-signature").
      with(
        body: {
          auth_algo: "AUTH-ALGO",
          cert_url: "CERT-URL",
          transmission_id: "TRANSMISSION-ID",
          transmission_sig: "TRANSMISSION-SIG",
          transmission_time: "TRANSMISSION-TIME",
          webhook_id: Exercism.secrets.paypal_webhook_id,
          webhook_event: { resource: { id: 7 } }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      ).
      to_return(status: 200, body: { verification_status: "SUCCESS" }.to_json, headers: { 'Content-Type' => 'application/json' })

    headers = {
      'PAYPAL-AUTH-ALGO' => 'AUTH-ALGO',
      'PAYPAL-CERT-URL' => 'CERT-URL',
      'PAYPAL-TRANSMISSION-ID' => 'TRANSMISSION-ID',
      'PAYPAL-TRANSMISSION-SIG' => 'TRANSMISSION-SIG',
      'PAYPAL-TRANSMISSION-TIME' => 'TRANSMISSION-TIME'
    }
    body = { resource: { id: 7 } }

    Webhooks::Paypal::RequestAccessToken.expects(:call).returns(SecureRandom.uuid)

    Webhooks::Paypal::VerifySignature.(headers, body)
  end

  test "raises when signature is not valid" do
    stub_request(:post, "https://api-m.paypal.com/v1/notifications/verify-webhook-signature").
      with(
        body: {
          auth_algo: "AUTH-ALGO",
          cert_url: "CERT-URL",
          transmission_id: "TRANSMISSION-ID",
          transmission_sig: "TRANSMISSION-SIG",
          transmission_time: "TRANSMISSION-TIME",
          webhook_id: Exercism.secrets.paypal_webhook_id,
          webhook_event: { resource: { id: 7 } }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      ).
      to_return(status: 200, body: { verification_status: "FAILURE" }.to_json, headers: { 'Content-Type' => 'application/json' })

    headers = {
      'PAYPAL-AUTH-ALGO' => 'AUTH-ALGO',
      'PAYPAL-CERT-URL' => 'CERT-URL',
      'PAYPAL-TRANSMISSION-ID' => 'TRANSMISSION-ID',
      'PAYPAL-TRANSMISSION-SIG' => 'TRANSMISSION-SIG',
      'PAYPAL-TRANSMISSION-TIME' => 'TRANSMISSION-TIME'
    }
    body = { resource: { id: 7 } }

    Webhooks::Paypal::RequestAccessToken.expects(:call).returns(SecureRandom.uuid)

    assert_raises Webhooks::Paypal::VerifySignature::SignatureVerificationError do
      Webhooks::Paypal::VerifySignature.(headers, body)
    end
  end

  test "raises when response is not success" do
    stub_request(:post, "https://api-m.paypal.com/v1/notifications/verify-webhook-signature").
      with(
        body: {
          auth_algo: "AUTH-ALGO",
          cert_url: "CERT-URL",
          transmission_id: "TRANSMISSION-ID",
          transmission_sig: "TRANSMISSION-SIG",
          transmission_time: "TRANSMISSION-TIME",
          webhook_id: Exercism.secrets.paypal_webhook_id,
          webhook_event: { resource: { id: 7 } }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      ).
      to_return(status: 401, body: '', headers: {})

    headers = {
      'PAYPAL-AUTH-ALGO' => 'AUTH-ALGO',
      'PAYPAL-CERT-URL' => 'CERT-URL',
      'PAYPAL-TRANSMISSION-ID' => 'TRANSMISSION-ID',
      'PAYPAL-TRANSMISSION-SIG' => 'TRANSMISSION-SIG',
      'PAYPAL-TRANSMISSION-TIME' => 'TRANSMISSION-TIME'
    }
    body = { resource: { id: 7 } }

    Webhooks::Paypal::RequestAccessToken.expects(:call).returns(SecureRandom.uuid)

    assert_raises Webhooks::Paypal::VerifySignature::SignatureVerificationError do
      Webhooks::Paypal::VerifySignature.(headers, body)
    end
  end

  test "raises when response JSON is not valid" do
    stub_request(:post, "https://api-m.paypal.com/v1/notifications/verify-webhook-signature").
      with(
        body: {
          auth_algo: "AUTH-ALGO",
          cert_url: "CERT-URL",
          transmission_id: "TRANSMISSION-ID",
          transmission_sig: "TRANSMISSION-SIG",
          transmission_time: "TRANSMISSION-TIME",
          webhook_id: Exercism.secrets.paypal_webhook_id,
          webhook_event: { resource: { id: 7 } }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      ).
      to_return(status: 200, body: "{ verification_stat", headers: { 'Content-Type' => 'application/json' })

    headers = {
      'PAYPAL-AUTH-ALGO' => 'AUTH-ALGO',
      'PAYPAL-CERT-URL' => 'CERT-URL',
      'PAYPAL-TRANSMISSION-ID' => 'TRANSMISSION-ID',
      'PAYPAL-TRANSMISSION-SIG' => 'TRANSMISSION-SIG',
      'PAYPAL-TRANSMISSION-TIME' => 'TRANSMISSION-TIME'
    }
    body = { resource: { id: 7 } }

    Webhooks::Paypal::RequestAccessToken.expects(:call).returns(SecureRandom.uuid)

    assert_raises Webhooks::Paypal::VerifySignature::SignatureVerificationError do
      Webhooks::Paypal::VerifySignature.(headers, body)
    end
  end
end
