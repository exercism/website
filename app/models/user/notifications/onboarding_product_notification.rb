class User::Notifications::OnboardingProductNotification < User::Notification
  def url = Exercism::Routes.community_url
  def image_type = :icon
  def image_path = "icons/community.svg"
  def email_communication_preferences_key = "receive_onboarding_emails"

  # Users should only receive this email once
  def guard_params = ""
end
