require "test_helper"

class User::JoinPremiumTest < ActiveSupport::TestCase
  test "makes user premium user until specified date" do
    user = create :user, premium_until: nil
    premium_until = Time.current + 10.seconds

    # Sanity check
    refute user.premium?

    User::JoinPremium.(user, premium_until)

    assert user.premium?

    travel_to premium_until + 1.second
    refute user.premium?
  end
end
