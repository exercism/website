require "test_helper"

class User::Premium::JoinLifetimeTest < ActiveSupport::TestCase
  test "makes user premium for very long time" do
    user = create :user, premium_until: nil

    # Sanity check
    refute user.premium?

    User::Premium::JoinLifetime.(user)

    assert user.premium?

    travel_to Time.current + 99.years
    assert user.premium?
  end

  test "create notification" do
    user = create :user

    User::Notification::CreateEmailOnly.expects(:defer).with(user, :joined_lifetime_premium).once

    User::Premium::JoinLifetime.(user)
  end
end
