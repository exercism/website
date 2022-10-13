class User::Notifications::MentorFinishedDiscussionNotification < User::Notification
  params :discussion

  def url = discussion.student_url
  def image_type = :avatar
  def image_url = mentor.avatar_url
  def guard_params = "Discussion##{discussion.id}"

  def i18n_params
    {
      mentor_name: mentor.handle,
      track_title: solution.track.title,
      exercise_title: solution.exercise.title
    }
  end

  private
  def mentor = discussion.mentor
  def solution = discussion.solution
end
