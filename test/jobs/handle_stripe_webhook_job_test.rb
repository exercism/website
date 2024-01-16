require "test_helper"

class HandleStripeWebhookJobTest < ActiveJob::TestCase
  test "uses specific tolerance" do
    payload = RecursiveOpenStruct.new(
      type: "subscription",
      amount_in_cents: 1000,
      email: "",
      payment_intent: {
        type: "subscription",
        amount_in_cents: 1000,
        email: ""
      }
    )
    signature = SecureRandom.compact_uuid

    Stripe::Webhook.expects(:construct_event).with(
      payload, signature, Exercism.secrets.stripe_endpoint_secret,
      tolerance: 86_400
    ).returns(payload)

    HandleStripeWebhookJob.perform_now(signature, payload)
  end
end
