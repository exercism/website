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

  test "update flair" do
    user = create :user

    User::UpdateFlair.expects(:call).with(user)

    User::Premium::Expire.(user)
  end

  %w[nil light sepia].each do |theme|
    test "don't change theme when current theme is #{theme}" do
      user = create :user
      user.preferences.update!(theme:)

      User::Premium::Expire.(user)

      assert_equal theme, user.reload.preferences.theme
    end
  end

  %w[dark system].each do |theme|
    test "clear theme when current theme is #{theme}" do
      user = create :user
      user.preferences.update!(theme:)

      User::Premium::Expire.(user)

      assert_nil user.reload.preferences.theme
    end
  end
end
