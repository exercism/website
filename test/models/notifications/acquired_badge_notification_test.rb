require 'test_helper'

class Notifications::AcquiredBadgeNotificationTest < ActiveSupport::TestCase
  test "uniqueness_key" do
    user = create :user
    badge = create(:badge)

    notification = Notifications::AcquiredBadgeNotification.create!(
      user: user,
      params: {
        badge: badge
      }
    )
    key = "#{user.id}-acquired_badge-Badge##{badge.id}"
    assert_equal key, notification.uniqueness_key
  end

  test "text is valid" do
    user = create :user
    badge = create(:badge)

    notification = Notifications::AcquiredBadgeNotification.create!(
      user: user,
      params: {
        badge: badge
      }
    )
    assert_equal "You have been awarded the #{badge.name} badge.", notification.text
  end
end
