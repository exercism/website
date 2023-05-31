require "test_helper"

class Payments::PaymentTest < ActiveSupport::TestCase
  test "total_donated_in_dollars" do
    create :payments_payment, :donation, amount_in_cents: 100
    create :payments_payment, :donation, amount_in_cents: 300

    assert_equal 4.0, Payments::Payment.total_donated_in_dollars

    # Sanity check: premium payments are ignored
    create :payments_payment, :premium, amount_in_cents: 500

    assert_equal 4.0, Payments::Payment.total_donated_in_dollars
  end
end
