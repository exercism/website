require_relative '../../../test_base'

class Payments::Paypal::Payment::IPN::HandleWebAcceptTest < Payments::TestBase
  test "does not create a payment when payment_status is Completed" do
    paypal_payer_id = SecureRandom.uuid
    user = create(:user, paypal_payer_id:)
    payload = {
      "txn_id" => SecureRandom.uuid,
      "txn_type" => "web_accept",
      "payment_status" => "Completed",
      "payer_email" => user.email,
      "payer_id" => paypal_payer_id,
      "mc_gross" => "15.0",
      "item_name" => Exercism.secrets.paypal_donation_product_name,
      "custom" => user.id
    }

    Payments::Paypal::Payment::IPN::HandleWebAccept.(payload)

    refute Payments::Payment.exists?
    refute Payments::Subscription.exists?
    assert_equal 0, user.reload.total_donated_in_cents
    refute user.donated?
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

    test "ignore when payment_status is #{payment_status} and the payment is unknown" do
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
