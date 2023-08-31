class User::Notifications::NudgeStudentToReplyInDiscussionNotification < User::Notification
  params :discussion, :num_days_waiting

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
  def guard_params = "Discussion##{discussion.id}##{discussion.awaiting_student_since.to_date}##{num_days_waiting}"
end
