require_relative '../../test_base'

class Payments::Paypal::Subscription::HandleRecurringPaymentTest < Payments::TestBase
  test "creates payment linked to existing subscription" do
    freeze_time do
      payment_id = SecureRandom.uuid
      recurring_payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user, paypal_payer_id:)
      subscription = create(:payments_subscription, :paypal, external_id: recurring_payment_id, user:)
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_id" => payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => user.paypal_payer_id,
        "mc_gross" => "#{amount_in_dollars}.0"
      }

      Payments::Paypal::Subscription::HandleRecurringPayment.(payload)

      assert_equal 1, Payments::Payment.count
      payment = Payments::Payment.last
      assert_equal payment_id, payment.external_id
      assert_equal amount_in_cents, payment.amount_in_cents
      assert_nil payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :paypal, payment.provider
      assert_equal subscription, payment.subscription
      assert_equal amount_in_cents, user.reload.total_donated_in_cents
      assert_equal Time.current, user.first_donated_at
      assert user.donated?
    end
  end

  test "creates payment linked to unknown subscription" do
    freeze_time do
      payment_id = SecureRandom.uuid
      recurring_payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user, paypal_payer_id:)
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_id" => payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => user.paypal_payer_id,
        "mc_gross" => "#{amount_in_dollars}.0"
      }

      Payments::Paypal::Subscription::HandleRecurringPayment.(payload)

      assert_equal 1, Payments::Subscription.count
      subscription = Payments::Subscription.last
      assert_equal recurring_payment_id, subscription.external_id

      assert_equal 1, Payments::Payment.count
      payment = Payments::Payment.last
      assert_equal payment_id, payment.external_id
      assert_equal amount_in_cents, payment.amount_in_cents
      assert_nil payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :paypal, payment.provider
      assert_equal subscription, payment.subscription
      assert_equal amount_in_cents, user.reload.total_donated_in_cents
      assert_equal Time.current, user.first_donated_at
      assert user.donated?
    end
  end

  test "creates payment for unknown paypal payer id but known email" do
    freeze_time do
      payment_id = SecureRandom.uuid
      recurring_payment_id = SecureRandom.uuid
      user = create :user
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_id" => payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => SecureRandom.uuid,
        "mc_gross" => "#{amount_in_dollars}.0"
      }

      Payments::Paypal::Subscription::HandleRecurringPayment.(payload)

      assert_equal 1, Payments::Subscription.count
      subscription = Payments::Subscription.last
      assert_equal recurring_payment_id, subscription.external_id

      assert_equal 1, Payments::Payment.count
      payment = Payments::Payment.last
      assert_equal payment_id, payment.external_id
      assert_equal amount_in_cents, payment.amount_in_cents
      assert_nil payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :paypal, payment.provider
      assert_equal subscription, payment.subscription
      assert_equal amount_in_cents, user.reload.total_donated_in_cents
      assert_equal Time.current, user.first_donated_at
      assert user.donated?
    end
  end

  test "creates subscription if not already created" do
    freeze_time do
      payment_id = SecureRandom.uuid
      recurring_payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user, paypal_payer_id:)
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_id" => payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => user.paypal_payer_id,
        "mc_gross" => "#{amount_in_dollars}.0"
      }

      Payments::Paypal::Subscription::HandleRecurringPayment.(payload)

      assert_equal 1, Payments::Subscription.count
      subscription = Payments::Subscription.last
      assert_equal recurring_payment_id, subscription.external_id
      assert_equal amount_in_cents, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal :active, subscription.status
      assert_equal :paypal, subscription.provider
      assert user.reload.active_donation_subscription?
    end
  end

  test "creates subscription for unknown paypal payer id but known email" do
    freeze_time do
      payment_id = SecureRandom.uuid
      recurring_payment_id = SecureRandom.uuid
      user = create :user
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_id" => payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => SecureRandom.uuid,
        "mc_gross" => "#{amount_in_dollars}.0"
      }

      Payments::Paypal::Subscription::HandleRecurringPayment.(payload)

      assert_equal 1, Payments::Subscription.count
      subscription = Payments::Subscription.last
      assert_equal recurring_payment_id, subscription.external_id
      assert_equal amount_in_cents, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal :active, subscription.status
      assert_equal :paypal, subscription.provider
      assert user.reload.active_donation_subscription?
    end
  end

  test "ignore when paypal payer id and email are unknown" do
    payload = {
      "recurring_payment_id" => SecureRandom.uuid,
      "txn_type" => "recurring_payment_profile_created",
      "payment_status" => "Completed",
      "payer_email" => "unknown@test.org",
      "payer_id" => SecureRandom.uuid,
      "mc_gross" => "15.0"
    }

    Payments::Paypal::Subscription::HandleRecurringPayment.(payload)

    refute Payments::Payment.exists?
    refute Payments::Subscription.exists?
  end
end
