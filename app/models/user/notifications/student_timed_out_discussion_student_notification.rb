class User::Notifications::StudentTimedOutDiscussionStudentNotification < User::Notification
  params :discussion

  delegate :mentor, :exercise, :track, to: :discussion

  def url = discussion.student_url

  def i18n_params
    {
      mentor_name: mentor.handle,
      track_title: track.title,
      exercise_title: exercise.title
    }
  end

  def image_type = :avatar
  def image_url = mentor.avatar_url
  def guard_params = "Discussion##{discussion.id}"
  def email_communication_preferences_key = :email_on_student_timed_out_discussion_notification
end
