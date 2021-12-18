require 'test_helper'

class User::Notifications::AcquiredBadgeNotificationTest < ActiveSupport::TestCase
  include ActionView::Helpers::AssetUrlHelper

  test "keys are valid" do
    user = create :user
    badge = create(:contributor_badge)
    acquired_badge = create :user_acquired_badge, user: user, badge: badge

    notification = User::Notifications::AcquiredBadgeNotification.create!(user: user, params: { user_acquired_badge: acquired_badge })
    assert_equal "#{user.id}|acquired_badge|Badge##{badge.id}", notification.uniqueness_key
  end
end
