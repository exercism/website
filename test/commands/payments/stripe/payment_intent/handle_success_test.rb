require_relative '../../test_base'

class Payments::Stripe::PaymentIntent::HandleSuccessTest < Payments::TestBase
  setup do
    @customer_id = SecureRandom.uuid
    @user = create :user, stripe_customer_id: @customer_id
  end

  test "records a succeeded payment" do
    payment_intent = mock_stripe_payment_intent(SecureRandom.uuid, customer: @customer_id, status: "succeeded")
    Stripe::Checkout::Session.expects(:list).with({ payment_intent: payment_intent.id }).returns(OpenStruct.new(data: []))

    Payments::Stripe::Subscription::Create.expects(:call).never
    Payments::Stripe::Payment::Create.expects(:call).with(@user, payment_intent, subscription: nil)

    Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent:)
  end

  test "retrieves the payment intent by id" do
    payment_intent = mock_stripe_payment_intent(SecureRandom.uuid, customer: @customer_id, status: "succeeded")
    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent.id).returns(payment_intent)
    Stripe::Checkout::Session.expects(:list).returns(OpenStruct.new(data: []))

    Payments::Stripe::Payment::Create.expects(:call).with(@user, payment_intent, subscription: nil)

    Payments::Stripe::PaymentIntent::HandleSuccess.(id: payment_intent.id)
  end

  %w[requires_payment_method requires_confirmation requires_action processing canceled].each do |status|
    test "does not record a payment with status #{status}" do
      payment_intent = mock_stripe_payment_intent(SecureRandom.uuid, customer: @customer_id, status:)

      Payments::Stripe::Subscription::Create.expects(:call).never
      Payments::Stripe::Payment::Create.expects(:call).never

      Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent:)
    end
  end

  test "records a subscription and payment once the invoice is paid" do
    invoice_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    payment_intent = mock_stripe_payment_intent(
      SecureRandom.uuid, invoice_id:, customer: @customer_id, status: "succeeded"
    )
    invoice = mock_stripe_invoice(invoice_id, subscription_id, status: "paid")
    subscription_data = mock_stripe_subscription(subscription_id, 1500, status: "incomplete")
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    subscription = create(:payments_subscription, user: @user)
    Payments::Stripe::Subscription::Create.expects(:call).with(@user, subscription_data).returns(subscription)
    Payments::Stripe::Payment::Create.expects(:call).with(@user, payment_intent, subscription:)

    Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent:)
  end

  test "records a subscription and payment once the subscription is active" do
    invoice_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    payment_intent = mock_stripe_payment_intent(
      SecureRandom.uuid, invoice_id:, customer: @customer_id, status: "succeeded"
    )
    invoice = mock_stripe_invoice(invoice_id, subscription_id, status: "open")
    subscription_data = mock_stripe_subscription(subscription_id, 1500, status: "active")
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    Payments::Stripe::Subscription::Create.expects(:call).with(@user, subscription_data)
    Payments::Stripe::Payment::Create.expects(:call)

    Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent:)
  end

  test "does not record an unpaid subscription" do
    invoice_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    payment_intent = mock_stripe_payment_intent(
      SecureRandom.uuid, invoice_id:, customer: @customer_id, status: "succeeded"
    )
    invoice = mock_stripe_invoice(invoice_id, subscription_id, status: "open")
    subscription_data = mock_stripe_subscription(subscription_id, 1500, status: "incomplete")
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    Payments::Stripe::Subscription::Create.expects(:call).never
    Payments::Stripe::Payment::Create.expects(:call).never

    Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent:)
  end

  test "does nothing for an unknown customer" do
    payment_intent = mock_stripe_payment_intent(SecureRandom.uuid, customer: SecureRandom.uuid, status: "succeeded")

    Payments::Stripe::Payment::Create.expects(:call).never

    Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent:)
  end

  test "tracks checkout_succeeded for a new one-off payment" do
    payment_intent = mock_stripe_payment_intent(SecureRandom.uuid, customer: @customer_id, status: "succeeded")
    payment_intent.amount = 1600
    payment_intent.metadata = { trigger: "beg_modal" }
    Stripe::Checkout::Session.expects(:list).returns(OpenStruct.new(data: []))

    payment = create(:payments_payment, user: @user)
    Payments::Stripe::Payment::Create.expects(:call).with do |*|
      @user.data.update!(insiders_status: :active)
      true
    end.returns(payment)

    Analytics::TrackEvent.expects(:defer).with(
      @user,
      "checkout_succeeded",
      properties: {
        trigger: "beg_modal",
        payment_type: "payment",
        amount_in_cents: 1600,
        currency: "usd",
        became_insider: true
      }
    )

    Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent:)
  end

  test "tracks checkout_succeeded for a subscription's first invoice" do
    invoice_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    @user.data.update!(insiders_status: :active)
    payment_intent = mock_stripe_payment_intent(
      SecureRandom.uuid, invoice_id:, customer: @customer_id, status: "succeeded"
    )
    payment_intent.amount = 1000
    invoice = mock_stripe_invoice(invoice_id, subscription_id, status: "paid")
    invoice.billing_reason = "subscription_create"
    subscription_data = mock_stripe_subscription(subscription_id, 1000, status: "active")
    subscription_data.metadata = { trigger: "assistant_upsell_modal" }
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    subscription = create(:payments_subscription, user: @user)
    Payments::Stripe::Subscription::Create.expects(:call).returns(subscription)
    Payments::Stripe::Payment::Create.expects(:call).returns(create(:payments_payment, user: @user))

    Analytics::TrackEvent.expects(:defer).with(
      @user,
      "checkout_succeeded",
      properties: {
        trigger: "assistant_upsell_modal",
        payment_type: "subscription",
        amount_in_cents: 1000,
        currency: "usd",
        interval: "month",
        became_insider: false
      }
    )

    Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent:)
  end

  test "does not track a subscription renewal" do
    invoice_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    payment_intent = mock_stripe_payment_intent(
      SecureRandom.uuid, invoice_id:, customer: @customer_id, status: "succeeded"
    )
    invoice = mock_stripe_invoice(invoice_id, subscription_id, status: "paid")
    invoice.billing_reason = "subscription_cycle"
    subscription_data = mock_stripe_subscription(subscription_id, 1000, status: "active")
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    Payments::Stripe::Subscription::Create.expects(:call).returns(create(:payments_subscription, user: @user))
    Payments::Stripe::Payment::Create.expects(:call).returns(create(:payments_payment, user: @user))

    Analytics::TrackEvent.expects(:defer).never

    Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent:)
  end

  test "does not track a payment that was already recorded" do
    payment_intent = mock_stripe_payment_intent(SecureRandom.uuid, customer: @customer_id, status: "succeeded")
    Stripe::Checkout::Session.expects(:list).returns(OpenStruct.new(data: []))

    existing = create(:payments_payment, user: @user)
    Payments::Stripe::Payment::Create.expects(:call).returns(Payments::Payment.find(existing.id))

    Analytics::TrackEvent.expects(:defer).never

    Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent:)
  end
end
