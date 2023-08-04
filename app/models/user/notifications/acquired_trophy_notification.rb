class User::Notifications::AcquiredTrophyNotification < User::Notification
  params :user_track_acquired_trophy

  delegate :user_id, :track_id, :trophy_id, to: :user_track_acquired_trophy

  def url = Exercism::Routes.profile_url(user_id)
  def image_type; end
  def image_url; end

  def guard_params = "Track##{track_id}|Trophy##{trophy_id}"
end
