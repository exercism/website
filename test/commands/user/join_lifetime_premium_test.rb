require "test_helper"

class User::JoinLifetimePremiumTest < ActiveSupport::TestCase
  test "makes user premium for very long time" do
    user = create :user, premium_until: nil

    # Sanity check
    refute user.premium?

    User::JoinLifetimePremium.(user)

    assert user.premium?

    travel_to Time.current + 99.years
    assert user.premium?
  end
end
