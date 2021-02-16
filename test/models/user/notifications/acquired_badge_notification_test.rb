require 'test_helper'

class User::Notifications::AcquiredBadgeNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user
    badge = create(:badge)

    notification = User::Notifications::AcquiredBadgeNotification.create!(
      user: user,
      params: {
        badge: badge
      }
    )
    assert_equal "#{user.id}-acquired_badge-Badge##{badge.id}", notification.uniqueness_key
    assert_equal "You have been awarded the #{badge.name} badge.", notification.text
    assert_equal "#", notification.url
  end
end
