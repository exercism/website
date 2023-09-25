class User::Notifications::NudgeMentorToReplyInDiscussionNotification < User::Notification
  params :discussion, :num_days_waiting

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
  def guard_params = "Discussion##{discussion.id}##{discussion.awaiting_mentor_since.to_date}##{num_days_waiting}"
  def email_communication_preferences_key = :email_on_nudge_mentor_to_reply_in_discussion_notification
  def num_days_to_time_out = Mentor::Discussion::NUM_DAYS_BEFORE_TIME_OUT - num_days_waiting
end
