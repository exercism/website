require "test_helper"

class User::Premium::JoinTest < ActiveSupport::TestCase
  test "makes user premium user until specified date" do
    user = create :user, premium_until: nil
    premium_until = Time.current + 10.seconds

    # Sanity check
    refute user.premium?

    User::Premium::Join.(user, premium_until)

    assert user.premium?

    travel_to premium_until + 1.second
    refute user.premium?
  end

  test "create notification" do
    user = create :user

    User::Notification::CreateEmailOnly.expects(:defer).with(user, :joined_premium).once

    User::Premium::Join.(user, Time.current + 1.month)
  end
end
