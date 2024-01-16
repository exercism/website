class User::Notifications::MentorTimedOutDiscussionMentorNotification < User::Notification
  params :discussion

  delegate :student, :exercise, :track, to: :discussion

  def url = discussion.mentor_url

  def i18n_params
    {
      student_name: student.handle,
      track_title: track.title,
      exercise_title: exercise.title
    }
  end

  def image_type = :avatar
  def image_url = student.avatar_url
  def guard_params = "Discussion##{discussion.id}"
  def email_communication_preferences_key = :email_on_mentor_timed_out_discussion_notification
end
