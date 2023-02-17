class User::Notifications::OnboardingFundraisingNotification < User::Notification
  def url = Exercism::Routes.donate_url
  def image_type = :icon
  def image_path = "icons/donate.svg"
  def email_communication_preferences_key = "email_on_onboarding"

  # Users should only receive this email once
  def guard_params = ""
end
