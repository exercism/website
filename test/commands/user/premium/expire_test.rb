require "test_helper"

class User::Premium::ExpireTest < ActiveSupport::TestCase
  test "create notification" do
    user = create :user

    User::Notification::CreateEmailOnly.expects(:defer).with(user, :expired_premium).once

    User::Premium::Expire.(user)
  end
end
