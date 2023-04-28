require_relative '../../test_base'

class Donations::Paypal::Payment::HandlePaymentCreatedTest < Donations::TestBase
  test "creates correctly for known paypay_payer_id" do
    freeze_time do
      payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user, paypal_payer_id:)
      amount_in_dollars = 15
      amount_in_cents = 1500
      resource = {
        id: payment_id,
        transactions: [
          {
            amount: {
              total: "#{amount_in_dollars}.0"
            }
          }
        ],
        payer: {
          payer_info: {
            email: "customer@example.com",
            payer_id: paypal_payer_id
          }
        }
      }

      Donations::Paypal::Payment::HandlePaymentCreated.(resource)

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
    end
  end

  test "creates correctly for unknown paypay_payer_id but known email" do
    freeze_time do
      payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create :user, paypal_payer_id: nil
      amount_in_dollars = 15
      amount_in_cents = 1500
      resource = {
        id: payment_id,
        transactions: [
          {
            amount: {
              total: "#{amount_in_dollars}.0"
            }
          }
        ],
        payer: {
          payer_info: {
            email: user.email,
            payer_id: paypal_payer_id
          }
        }
      }

      Donations::Paypal::Payment::HandlePaymentCreated.(resource)

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
      assert_equal paypal_payer_id, user.paypal_payer_id
      assert user.donated?
    end
  end

  test "ignores unknown payer" do
    resource = {
      id: "PAY-1",
      transactions: [
        {
          amount: {
            total: "15.0"
          }
        }
      ],
      payer: {
        payer_info: {
          email: "test@exercism.org",
          payer_id: "CUS-1"
        }
      }
    }

    Donations::Paypal::Payment::HandlePaymentCreated.(resource)

    refute Donations::Payment.exists?
    refute Donations::Subscription.exists?
  end

  test "creates subscription if billing_agreement_id present and no subscription already created" do
    payment_id = SecureRandom.uuid
    paypal_payer_id = SecureRandom.uuid
    billing_agreement_id = SecureRandom.uuid
    create(:user, paypal_payer_id:)
    amount_in_dollars = 15
    amount_in_cents = 1500
    resource = {
      id: payment_id,
      billing_agreement_id:,
      transactions: [
        {
          amount: {
            total: "#{amount_in_dollars}.0"
          }
        }
      ],
      payer: {
        payer_info: {
          email: "customer@example.com",
          payer_id: paypal_payer_id
        }
      }
    }

    Donations::Paypal::Payment::HandlePaymentCreated.(resource)

    assert_equal 1, Donations::Payment.count
    assert_equal 1, Donations::Subscription.count

    payment = Donations::Payment.last
    subscription = Donations::Subscription.last
    assert_equal subscription, payment.subscription
    assert_equal billing_agreement_id, subscription.external_id
    assert_equal amount_in_cents, subscription.amount_in_cents
    assert_equal :paypal, subscription.provider
  end

  test "created payment linked to existing subscription with specified billing_agreement_id" do
    payment_id = SecureRandom.uuid
    paypal_payer_id = SecureRandom.uuid
    billing_agreement_id = SecureRandom.uuid
    create(:user, paypal_payer_id:)
    subscription = create :donations_subscription, provider: :paypal, external_id: billing_agreement_id
    amount_in_dollars = 15
    resource = {
      id: payment_id,
      billing_agreement_id:,
      transactions: [
        {
          amount: {
            total: "#{amount_in_dollars}.0"
          }
        }
      ],
      payer: {
        payer_info: {
          email: "customer@example.com",
          payer_id: paypal_payer_id
        }
      }
    }

    Donations::Paypal::Payment::HandlePaymentCreated.(resource)

    assert_equal 1, Donations::Payment.count
    assert_equal 1, Donations::Subscription.count

    payment = Donations::Payment.last
    assert_equal subscription, payment.subscription
  end
end
