require_relative '../../test_base'

class Payments::Paypal::Payment::UpdateAmountTest < Payments::TestBase
  test "updates payment amount_in_cents" do
    new_amount = 3
    new_amount_in_cents = new_amount * 100

    payment = create :payments_payment, :paypal, amount_in_cents: 50

    refute_equal new_amount_in_cents, payment.amount_in_cents

    Payments::Paypal::Payment::UpdateAmount.(payment.external_id, new_amount)

    assert_equal new_amount_in_cents, payment.reload.amount_in_cents
    assert_equal new_amount_in_cents, payment.user.total_donated_in_cents
  end
end
