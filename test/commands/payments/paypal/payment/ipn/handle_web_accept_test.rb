require_relative '../../../test_base'

class Payments::Paypal::Payment::IPN::HandleWebAcceptTest < Payments::TestBase
  test "create payment when payment_status is Completed" do
    freeze_time do
      payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user, paypal_payer_id:)
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "txn_id" => payment_id,
        "txn_type" => "web_accept",
        "payment_status" => "Completed",
        "payer_email" => "unknown@test.org",
        "payer_id" => paypal_payer_id,
        "mc_gross" => "#{amount_in_dollars}.0",
        "item_name" => Exercism.secrets.paypal_donation_product_name
      }

      Payments::Paypal::Payment::IPN::HandleWebAccept.(payload)

      assert_equal 1, Payments::Payment.count
      refute Payments::Subscription.exists?

      payment = Payments::Payment.last
      assert_equal payment_id, payment.external_id
      assert_equal amount_in_cents, payment.amount_in_cents
      assert_nil payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :paypal, payment.provider
      assert_nil payment.subscription
      assert_equal amount_in_cents, user.reload.total_donated_in_cents
      assert_equal Time.current, user.first_donated_at
    end
  end

  test "create payment for unknown paypal payer id but known email" do
    freeze_time do
      payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user)
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "txn_id" => payment_id,
        "txn_type" => "web_accept",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => paypal_payer_id,
        "mc_gross" => "#{amount_in_dollars}.0",
        "item_name" => Exercism.secrets.paypal_donation_product_name
      }

      Payments::Paypal::Payment::IPN::HandleWebAccept.(payload)

      assert_equal 1, Payments::Payment.count

      payment = Payments::Payment.last
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

  test "create payment for unknown paypal payer id but user email specified in custom field" do
    freeze_time do
      payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user)
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "txn_id" => payment_id,
        "txn_type" => "web_accept",
        "payment_status" => "Completed",
        "payer_email" => "unknown@test.org",
        "payer_id" => paypal_payer_id,
        "mc_gross" => "#{amount_in_dollars}.0",
        "item_name" => Exercism.secrets.paypal_donation_product_name,
        "custom" => user.id
      }

      Payments::Paypal::Payment::IPN::HandleWebAccept.(payload)

      assert_equal 1, Payments::Payment.count

      payment = Payments::Payment.last
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

  %w[Canceled_Reversal Refunded Reversed].each do |payment_status|
    test "update payment amount when payment_status is #{payment_status}" do
      payment = create :payments_payment, :paypal, amount_in_cents: 300
      new_amount_in_dollars = 5
      new_amount_in_cents = new_amount_in_dollars * 100
      payload = {
        "txn_id" => payment.external_id,
        "txn_type" => "web_accept",
        "payment_status" => payment_status,
        "mc_gross" => "#{new_amount_in_dollars}.0",
        "item_name" => Exercism.secrets.paypal_donation_product_name
      }

      Payments::Paypal::Payment::IPN::HandleWebAccept.(payload)

      assert_equal new_amount_in_cents, payment.reload.amount_in_cents
      assert_equal new_amount_in_cents, payment.user.reload.total_donated_in_cents
    end
  end

  %w[Canceled_Reversal Completed Refunded Reversed].each do |payment_status|
    test "ignore when payment_status is #{payment_status} and paypal payer id and email are unknown" do
      payload = {
        "txn_id" => SecureRandom.uuid,
        "txn_type" => "web_accept",
        "payment_status" => payment_status,
        "payer_email" => "unknown@test.org",
        "payer_id" => SecureRandom.uuid,
        "mc_gross" => "15.0",
        "item_name" => Exercism.secrets.paypal_donation_product_name
      }

      Payments::Paypal::Payment::IPN::HandleWebAccept.(payload)

      refute Payments::Payment.exists?
      refute Payments::Subscription.exists?
    end
  end

  %w[Created Denied Expired Failed Pending Processed Voided].each do |payment_status|
    test "ignore when payment_status is #{payment_status}" do
      payload = {
        "txn_id" => SecureRandom.uuid,
        "txn_type" => "web_accept",
        "payment_status" => payment_status,
        "item_name" => Exercism.secrets.paypal_donation_product_name
      }

      Payments::Paypal::Payment::IPN::HandleWebAccept.(payload)

      refute Payments::Payment.exists?
      refute Payments::Subscription.exists?
    end
  end
end
