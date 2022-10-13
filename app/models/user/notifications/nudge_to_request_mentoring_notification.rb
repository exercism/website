class User::Notifications::NudgeToRequestMentoringNotification < User::Notification
  def url = Exercism::Routes.track_url(track, notification_uuid: uuid, anchor: "mentoring")

  def image_type = :icon

  def image_path = "icons/mentoring-gradient.svg"

  def guard_params
    ""
  end

  def email_communication_preferences_key = :email_on_nudge_notification
end
