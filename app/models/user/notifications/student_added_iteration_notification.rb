class User::Notifications::StudentAddedIterationNotification < User::Notification
  params :discussion, :iteration

  def url = discussion.mentor_url

  def i18n_params
    {
      student_name: student.handle,
      iteration_idx: iteration.idx,
      track_title: track.title,
      exercise_title: exercise.title
    }
  end

  def image_type = :avatar
  def image_url = student.avatar_url
  def guard_params = "Discussion##{discussion.id}|Iteration##{iteration.id}"

  private
  def track = iteration.solution.track
  def exercise = iteration.solution.exercise

  def student = discussion.student
end
