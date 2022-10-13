class User::Notifications::JoinedExercismNotification < User::Notification
  def url = Exercism::Routes.dashboard_url
  def image_type; end
  def image_url; end

  def guard_params
    "" # Users should only have this badge once
  end

  def email_communication_preferences_key
    nil # No email key for this - it must be sent.
  end
end
