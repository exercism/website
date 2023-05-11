require_relative '../../test_base'

class Donations::Paypal::Subscription::HandleRecurringPaymentProfileCreatedTest < Donations::TestBase
  test "creates subscription" do
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
        "payer_id" => paypal_payer_id,
        "mc_gross" => "#{amount_in_dollars}.0"
      }

      Donations::Paypal::Payment::HandleWebAccept.(payload)

      assert_equal 1, Donations::Payment.count

      payment = Donations::Payment.last
      assert_equal payment_id, payment.external_id
      assert_equal amount_in_cents, payment.amount_in_cents
      assert_nil payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :paypal, payment.provider
      assert_nil payment.subscription
      assert_equal amount_in_cents, user.reload.total_donated_in_cents
      assert_equal Time.current, user.first_donated_at
      assert user.donated?

      Donations::Paypal::Subscription::HandleRecurringPaymentProfileCreated.(resource)

      assert_equal 1, Donations::Subscription.count

      subscription = Donations::Subscription.last
      assert_equal subscription_id, subscription.external_id
      assert_equal amount_in_cents, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal :active, subscription.status
      assert_equal :paypal, subscription.provider
      assert user.reload.active_donation_subscription?
    end
  end

  test "creates correctly for unknown paypay_payer_id but known email" do
    freeze_time do
      subscription_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user, paypal_payer_id: nil)
      amount_in_dollars = 15
      amount_in_cents = 1500
      resource = {
        id: subscription_id,
        plan: {
          payment_definitions: [
            {
              amount: {
                value: "#{amount_in_dollars}.0"
              }
            }
          ]
        },
        payer: {
          payer_info: {
            email: user.email,
            payer_id: paypal_payer_id
          }
        }
      }

      Donations::Paypal::Subscription::HandleRecurringPaymentProfileCreated.(resource)

      assert_equal 1, Donations::Subscription.count

      subscription = Donations::Subscription.last
      assert_equal subscription_id, subscription.external_id
      assert_equal amount_in_cents, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal :active, subscription.status
      assert_equal :paypal, subscription.provider
      assert user.reload.active_donation_subscription?
    end
  end

  test "ignores unknown payer" do
    resource = {
      id: SecureRandom.uuid,
      plan: {
        payment_definitions: [
          {
            amount: {
              value: "5.0"
            }
          }
        ]
      },
      payer: {
        payer_info: {
          email: "test@exercism.org",
          payer_id: "CUS-1"
        }
      }
    }

    Donations::Paypal::Subscription::HandleRecurringPaymentProfileCreated.(resource)

    refute Donations::Payment.exists?
    refute Donations::Subscription.exists?
  end
end
