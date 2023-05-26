require "test_helper"

class User::Premium::ExpireTest < ActiveSupport::TestCase
  test "user loses premium" do
    user = create :user, :premium

    assert user.premium?

    User::Premium::Expire.(user)

    refute user.premium?
  end

  test "create notification" do
    user = create :user

    User::Notification::CreateEmailOnly.expects(:defer).with(user, :expired_premium).once

    User::Premium::Expire.(user)
  end
end
