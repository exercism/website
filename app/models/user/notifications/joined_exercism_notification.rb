class User::Notifications::JoinedExercismNotification < User::Notification
  def url = Exercism::Routes.dashboard_url
  def image_type; end
  def image_url; end

  # Users should only have this notification once
  def guard_params = ""

  def email_communication_preferences_key = :receive_product_updates
end
