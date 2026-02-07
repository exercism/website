require_relative '../test_base'

class Payments::Stripe::ReconcilePaymentsTest < Payments::TestBase
  test "syncs succeeded payment intents and creates payment records" do
    freeze_time do
      user = create :user, stripe_customer_id: "cus_123"
      pi_id = "pi_#{SecureRandom.hex(8)}"
      receipt_url = "https://receipt.stripe.com/#{SecureRandom.hex(8)}"
      since = 90.days.ago

      pis = [build_payment_intent(pi_id, customer: "cus_123", amount: 1500, receipt_url:)]
      stub_payment_intents_list(pis, created_gte: since.to_i)

      Payments::Stripe::ReconcilePayments.(since:)

      assert_equal 1, Payments::Payment.count
      payment = Payments::Payment.last
      assert_equal pi_id, payment.external_id
      assert_equal 1500, payment.amount_in_cents
      assert_equal receipt_url, payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :stripe, payment.provider
    end
  end

  test "skips payment intents already in the database" do
    freeze_time do
      user = create :user, stripe_customer_id: "cus_123"
      pi_id = "pi_#{SecureRandom.hex(8)}"
      since = 90.days.ago
      create :payments_payment, :stripe, external_id: pi_id, user: user

      pis = [build_payment_intent(pi_id, customer: "cus_123", amount: 1500)]
      stub_payment_intents_list(pis, created_gte: since.to_i)

      Payments::Stripe::ReconcilePayments.(since:)

      assert_equal 1, Payments::Payment.count
    end
  end

  test "skips bootcamp payments with checkout session" do
    freeze_time do
      create :user, stripe_customer_id: "cus_123"
      since = 90.days.ago

      pis = [build_payment_intent("pi_bootcamp", customer: "cus_123", amount: 4900)]
      stub_payment_intents_list(pis, created_gte: since.to_i)
      stub_checkout_session("pi_bootcamp", exists: true)

      Payments::Stripe::ReconcilePayments.(since:)

      assert_equal 0, Payments::Payment.count
    end
  end

  test "skips payment intents without a customer" do
    freeze_time do
      since = 90.days.ago

      pis = [build_payment_intent("pi_no_cus", customer: nil, amount: 500)]
      stub_payment_intents_list(pis, created_gte: since.to_i)

      Payments::Stripe::ReconcilePayments.(since:)

      assert_equal 0, Payments::Payment.count
    end
  end

  test "skips payment intents for unknown customers" do
    freeze_time do
      since = 90.days.ago

      pis = [build_payment_intent("pi_unknown", customer: "cus_unknown", amount: 1000)]
      stub_payment_intents_list(pis, created_gte: since.to_i)

      Payments::Stripe::ReconcilePayments.(since:)

      assert_equal 0, Payments::Payment.count
    end
  end

  test "associates subscription for invoice-linked payments" do
    freeze_time do
      user = create :user, stripe_customer_id: "cus_123"
      subscription = create :payments_subscription, user: user, external_id: "sub_abc", provider: :stripe
      invoice_id = "in_#{SecureRandom.hex(8)}"
      since = 90.days.ago

      pis = [build_payment_intent("pi_sub", customer: "cus_123", amount: 999, invoice: invoice_id)]
      stub_payment_intents_list(pis, created_gte: since.to_i)

      stub_request(:get, "https://api.stripe.com/v1/invoices/#{invoice_id}").
        to_return(
          status: 200,
          body: { id: invoice_id, object: "invoice", subscription: "sub_abc" }.to_json,
          headers: { 'Content-Type': 'application/json' }
        )

      Payments::Stripe::ReconcilePayments.(since:)

      assert_equal 1, Payments::Payment.count
      assert_equal subscription, Payments::Payment.last.subscription
    end
  end

  test "handles pagination across multiple pages" do
    freeze_time do
      create :user, stripe_customer_id: "cus_123"
      since = 90.days.ago
      pi_1 = build_payment_intent("pi_page1", customer: "cus_123", amount: 100)
      pi_2 = build_payment_intent("pi_page2", customer: "cus_123", amount: 200)

      stub_payment_intents_request(
        created_gte: since.to_i,
        body: { object: "list", data: [pi_1], has_more: true, url: "/v1/payment_intents" }
      )

      stub_payment_intents_request(
        created_gte: since.to_i,
        starting_after: "pi_page1",
        body: { object: "list", data: [pi_2], has_more: false, url: "/v1/payment_intents" }
      )

      Payments::Stripe::ReconcilePayments.(since:)

      assert_equal 2, Payments::Payment.count
    end
  end

  test "continues processing after individual payment errors" do
    freeze_time do
      create :user, stripe_customer_id: "cus_123"
      since = 90.days.ago

      pis = [
        build_payment_intent("pi_fail", customer: "cus_123", amount: 100),
        build_payment_intent("pi_ok", customer: "cus_123", amount: 200)
      ]
      stub_payment_intents_list(pis, created_gte: since.to_i)

      User::InsidersStatus::UpdateForPayment.stubs(:call).
        raises(RuntimeError.new("test error")).then.returns(nil)

      Payments::Stripe::ReconcilePayments.(since:)

      # Both payments are created (DB insert happens before the error),
      # and the second payment is still processed despite the first one's side effects failing
      assert_equal 2, Payments::Payment.count
      assert Payments::Payment.exists?(external_id: "pi_ok")
    end
  end

  test "records donation with billing email but no checkout session" do
    freeze_time do
      create :user, stripe_customer_id: "cus_123"
      since = 90.days.ago

      pis = [build_payment_intent("pi_email_donor", customer: "cus_123", amount: 1500)]
      stub_payment_intents_list(pis, created_gte: since.to_i)
      stub_checkout_session("pi_email_donor", exists: false)

      Payments::Stripe::ReconcilePayments.(since:)

      assert_equal 1, Payments::Payment.count
    end
  end

  test "does not send thank-you emails" do
    freeze_time do
      create :user, stripe_customer_id: "cus_123"
      since = 90.days.ago

      pis = [build_payment_intent("pi_no_email", customer: "cus_123", amount: 1500)]
      stub_payment_intents_list(pis, created_gte: since.to_i)

      Payments::Payment::SendEmail.expects(:defer).never

      Payments::Stripe::ReconcilePayments.(since:)
    end
  end

  test "passes actual Stripe payment date as donated_at" do
    freeze_time do
      user = create :user, stripe_customer_id: "cus_123"
      stripe_created = 1_700_000_000
      since = 90.days.ago

      pis = [build_payment_intent("pi_dated", customer: "cus_123", amount: 1500, created: stripe_created)]
      stub_payment_intents_list(pis, created_gte: since.to_i)

      Payments::Stripe::ReconcilePayments.(since:)

      assert_equal Time.at(stripe_created).utc, user.reload.first_donated_at
    end
  end

  test "respects custom since parameter" do
    freeze_time do
      create :user, stripe_customer_id: "cus_123"
      since = 1.year.ago

      pis = [build_payment_intent("pi_old", customer: "cus_123", amount: 500)]
      stub_payment_intents_list(pis, created_gte: since.to_i)

      Payments::Stripe::ReconcilePayments.(since:)
    end
  end

  private
  def stub_payment_intents_list(payment_intents, created_gte:)
    stub_payment_intents_request(
      created_gte:,
      body: {
        object: "list",
        data: payment_intents,
        has_more: false,
        url: "/v1/payment_intents"
      }
    )
  end

  def stub_payment_intents_request(body:, created_gte:, starting_after: nil)
    url = "https://api.stripe.com/v1/payment_intents?created%5Bgte%5D=#{created_gte}" \
          "&expand%5B%5D=data.latest_charge&limit=100"
    url += "&starting_after=#{starting_after}" if starting_after

    stub_request(:get, url).
      to_return(
        status: 200,
        body: body.to_json,
        headers: { 'Content-Type': 'application/json' }
      )
  end

  def stub_checkout_session(payment_intent_id, exists:)
    data = exists ? [{ id: "cs_#{SecureRandom.hex(8)}", object: "checkout.session" }] : []
    stub_request(:get, "https://api.stripe.com/v1/checkout/sessions?payment_intent=#{payment_intent_id}").
      to_return(
        status: 200,
        body: { object: "list", data:, has_more: false, url: "/v1/checkout/sessions" }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )
  end

  def build_payment_intent(id, customer:, amount:, receipt_url: nil,
                           invoice: nil, created: Time.current.to_i)
    stub_checkout_session(id, exists: false)

    {
      id:,
      object: "payment_intent",
      amount:,
      customer:,
      status: "succeeded",
      created:,
      invoice:,
      latest_charge: {
        id: "ch_#{SecureRandom.hex(8)}",
        object: "charge",
        receipt_url:
      }
    }
  end
end
