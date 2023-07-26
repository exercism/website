class User::Notifications::JoinedInsidersNotification < User::Notification
  def url = Exercism::Routes.insiders_url
  def image_type; end
  def image_url; end

  # Users should only have this notification once
  def guard_params = ""

  def email_communication_preferences_key = :email_about_insiders
end
