require_relative '../../../test_base'

class Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCreatedTest < Payments::TestBase
  test "creates subscription" do
    freeze_time do
      recurring_payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user, paypal_payer_id:)
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => paypal_payer_id,
        "amount" => "#{amount_in_dollars}.0",
        "product_name" => Exercism.secrets.paypal_donation_product_name,
        "payment_cycle" => "Monthly"
      }

      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCreated.(payload)

      refute Payments::Payment.exists?
      assert_equal 1, Payments::Subscription.count
      subscription = Payments::Subscription.last
      assert_equal recurring_payment_id, subscription.external_id
      assert_equal amount_in_cents, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal :active, subscription.status
      assert_equal :paypal, subscription.provider
      assert_equal :month, subscription.interval
    end
  end

  test "creates premium subscription" do
    freeze_time do
      recurring_payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user, paypal_payer_id:)
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => paypal_payer_id,
        "amount" => "#{amount_in_dollars}.0",
        "product_name" => Exercism.secrets.paypal_premium_product_name,
        "payment_cycle" => "Monthly"
      }

      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCreated.(payload)

      refute Payments::Payment.exists?
      assert_equal 1, Payments::Subscription.count
      subscription = Payments::Subscription.last
      assert_equal recurring_payment_id, subscription.external_id
      assert_equal amount_in_cents, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal :active, subscription.status
      assert_equal :paypal, subscription.provider
      assert_equal :month, subscription.interval
    end
  end

  test "creates subscription for unknown paypal payer id but known email" do
    freeze_time do
      recurring_payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create :user
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => paypal_payer_id,
        "amount" => "#{amount_in_dollars}.0",
        "product_name" => Exercism.secrets.paypal_donation_product_name,
        "payment_cycle" => "Yearly"
      }

      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCreated.(payload)

      refute Payments::Payment.exists?
      assert_equal 1, Payments::Subscription.count
      subscription = Payments::Subscription.last
      assert_equal recurring_payment_id, subscription.external_id
      assert_equal amount_in_cents, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal :active, subscription.status
      assert_equal :paypal, subscription.provider
      assert_equal :year, subscription.interval
    end
  end

  test "creates subscription for unknown paypal payer id and email but known paypal subscription id" do
    freeze_time do
      recurring_payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create :user
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => "unknown@test.org",
        "payer_id" => paypal_payer_id,
        "amount" => "#{amount_in_dollars}.0",
        "product_name" => Exercism.secrets.paypal_donation_product_name,
        "payment_cycle" => "Yearly"
      }

      create(:payments_subscription, :paypal, :active, interval: :year, user:, external_id: recurring_payment_id,
        amount_in_cents:)

      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCreated.(payload)

      refute Payments::Payment.exists?
      assert_equal 1, Payments::Subscription.count
      subscription = Payments::Subscription.last
      assert_equal recurring_payment_id, subscription.external_id
      assert_equal amount_in_cents, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal paypal_payer_id, subscription.user.paypal_payer_id
      assert_equal :active, subscription.status
      assert_equal :paypal, subscription.provider
      assert_equal :year, subscription.interval
    end
  end

  test "ignore when paypal payer id and email are unknown" do
    payload = {
      "recurring_payment_id" => SecureRandom.uuid,
      "txn_type" => "recurring_payment_profile_created",
      "payment_status" => "Completed",
      "payer_email" => "unknown@test.org",
      "payer_id" => SecureRandom.uuid,
      "amount" => "15.0",
      "product_name" => Exercism.secrets.paypal_donation_product_name,
      "payment_cycle" => "Monthly"
    }

    Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCreated.(payload)

    refute Payments::Payment.exists?
    refute Payments::Subscription.exists?
  end
end
