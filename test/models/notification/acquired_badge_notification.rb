require 'test_helper'

class Notification::AcquiredBadgeNotificationTest < ActiveSupport::TestCase
  test "anti_duplicate_key" do
    user = create :user
    user_badge = create(:user_badge)
 
    notification = Notification::AcquiredBadgeNotification.create!(
      user: user,
      params: { 
        user_badge: user_badge
      }
    )
    key = "#{user.id}-acquired_badge-UserBadge##{user_badge.id}"
    assert_equal key, notification.anti_duplicate_key
  end

  test "text is valid" do
    user = create :user
    badge = create(:badge)
    user_badge = create(:user_badge, badge: badge)
 
    notification = Notification::AcquiredBadgeNotification.create!(
      user: user,
      params: { 
        user_badge: user_badge
      }
    )
    assert_equal "You have been awarded the #{badge.name} badge.", notification.text
  end
end



