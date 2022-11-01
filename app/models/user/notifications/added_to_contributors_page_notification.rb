class User::Notifications::AddedToContributorsPageNotification < User::Notification
  def url = Exercism::Routes.contributing_contributors_url
  def i18n_params = {}

  def image_type = :icon
  def image_path = "icons/contributors.svg"

  def guard_params
    "" # Users should only have this badge once
  end

  def email_communication_preferences_key = "email_on_general_update_notification"
end
