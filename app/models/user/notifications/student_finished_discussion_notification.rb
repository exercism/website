class User::Notifications::StudentFinishedDiscussionNotification < User::Notification
  params :discussion

  def url = discussion.mentor_url
  def image_type = :avatar
  def image_url = student.avatar_url
  def guard_params = "Discussion##{discussion.id}"

  def i18n_params
    {
      student_name: student.handle,
      track_title: solution.track.title,
      exercise_title: solution.exercise.title
    }
  end

  private
  def student = solution.user
  def solution = discussion.solution
end
