class User::Notifications::AcquiredBadgeNotification < User::Notification
  params :user_acquired_badge

  def url = Exercism::Routes.badges_journey_url
  def image_type; end
  def image_url; end

  def guard_params = "Badge##{user_acquired_badge.badge_id}"
end
