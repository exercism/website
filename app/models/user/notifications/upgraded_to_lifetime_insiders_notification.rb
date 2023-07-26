class User::Notifications::UpgradedToLifetimeInsidersNotification < User::Notification
  # TODO: determine what values to use
  def url = Exercism::Routes.dashboard_url
  def image_type; end
  def image_url; end

  # Users should only have this notification once
  def guard_params = ""

  # No email key for this - it must be sent.
  def email_communication_preferences_key = :receive_product_updates
end
