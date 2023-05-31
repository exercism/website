require 'test_helper'

class User::UpdateTotalDonatedInCentsTest < ActiveSupport::TestCase
  test "updates total_donated_in_cents" do
    user = create :user, total_donated_in_cents: 0

    User::UpdateTotalDonatedInCents.(user)
    assert_equal 0, user.total_donated_in_cents

    create :payments_payment, user:, amount_in_cents: 100
    User::UpdateTotalDonatedInCents.(user)
    assert_equal 100, user.total_donated_in_cents

    create :payments_payment, user:, amount_in_cents: 75
    User::UpdateTotalDonatedInCents.(user)
    assert_equal 175, user.total_donated_in_cents
  end
end
