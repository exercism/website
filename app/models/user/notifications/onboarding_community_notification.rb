class User::Notifications::OnboardingCommunityNotification < User::Notification
  def url = Exercism::Routes.community_url
  def image_type = :icon
  def image_path = "icons/community.svg"

  def guard_params
    "" # Users should only have this email once
  end

  def email_communication_preferences_key = "email_on_onboarding"
end
