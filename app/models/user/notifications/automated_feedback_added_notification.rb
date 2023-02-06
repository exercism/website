class User::Notifications::AutomatedFeedbackAddedNotification < User::Notification
  params :representation, :iteration

  # We don't need to point to a specific iteration as the feedback is guaranteed
  # to be added to the latest (active) iteration
  def url = Exercism::Routes.track_exercise_iterations_url(track, exercise)
  def image_type = :icon
  def image_url = exercise.icon_url
  def guard_params = "Iteration##{iteration.id}"

  def i18n_params
    {
      iteration_idx: iteration.idx,
      track_title: track.title,
      exercise_title: exercise.title,
      emphasis:
    }
  end

  def emphasis = representation.has_essential_feedback? ? 'strongly ' : nil
  def email_should_send? = super && iteration.created_at >= Time.utc(2022, 10, 1)

  delegate :track, :exercise, to: :iteration
end
