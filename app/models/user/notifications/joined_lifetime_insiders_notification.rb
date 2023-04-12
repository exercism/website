class User::Notifications::JoinedLifetimeInsidersNotification < User::Notification
  # TODO: determine what values to use
  def url = Exercism::Routes.dashboard_url
  def image_type; end
  def image_url; end

  # Users should only have this notification once
  def guard_params = ""
end
