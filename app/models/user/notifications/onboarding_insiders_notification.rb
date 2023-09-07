class User::Notifications::OnboardingInsidersNotification < User::Notification
  def url = Exercism::Routes.insiders_url
  def image_type = :icon
  def image_path = "icons/insiders.svg"
  def icon_filter = "none"
  def email_communication_preferences_key = "receive_onboarding_emails"

  # Users should only receive this email once
  def guard_params = ""
end
