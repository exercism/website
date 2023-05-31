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

  test "don't change existing, non-light theme" do
    user = create :user
    user.preferences.update!(theme: :system)

    User::Premium::Join.(user.reload, Time.current + 1.month)

    assert_equal 'system', user.preferences.theme
  end

  test "change light theme to dark" do
    user = create :user
    user.preferences.update!(theme: :light)

    User::Premium::Join.(user.reload, Time.current + 1.month)

    assert_equal 'dark', user.preferences.theme
  end

  test "change theme to dark if no theme was specified" do
    user = create :user
    user.preferences.update!(theme: nil)

    User::Premium::Join.(user.reload, Time.current + 1.month)

    assert_equal 'dark', user.preferences.theme
  end
end
