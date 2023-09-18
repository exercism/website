require_relative '../test_base'

class Payments::Payment::UpdateAmountTest < Payments::TestBase
  test "updates payment amount_in_cents" do
    new_amount_in_cents = 30

    payment = create :payments_payment, :github, amount_in_cents: 50

    refute_equal new_amount_in_cents, payment.amount_in_cents

    Payments::Payment::UpdateAmount.(payment.provider, payment.external_id, new_amount_in_cents)

    assert_equal new_amount_in_cents, payment.reload.amount_in_cents
    assert_equal new_amount_in_cents, payment.user.total_donated_in_cents
  end

  test "skips unknown payment" do
    old_amount_in_cents = 30

    payment = create :payments_payment, :github, amount_in_cents: old_amount_in_cents

    # Both provider and external ID are different
    Payments::Payment::UpdateAmount.(:stripe, 'unknown', 100)
    assert_equal old_amount_in_cents, payment.reload.amount_in_cents
    assert_equal 1, Payments::Payment.count

    # Provider is different
    Payments::Payment::UpdateAmount.(:stripe, payment.external_id, 100)
    assert_equal old_amount_in_cents, payment.reload.amount_in_cents
    assert_equal 1, Payments::Payment.count

    # External ID is different
    Payments::Payment::UpdateAmount.(payment.provider, 'unknown', 100)
    assert_equal old_amount_in_cents, payment.reload.amount_in_cents
    assert_equal 1, Payments::Payment.count
  end

  test "idempotent" do
    payment = create :payments_payment

    assert_idempotent_command do
      Payments::Payment::UpdateAmount.(payment.provider, payment.external_id, 100)
    end
  end
end
