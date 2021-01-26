class SerializeIteration
  include Mandate

  initialize_with :iteration

  def call
    {
      uuid: iteration.uuid,
      submission_uuid: iteration.submission.uuid,
      idx: iteration.idx,
      submission_method: iteration.submission.submitted_via,
      created_at: iteration.created_at.iso8601,
      tests_status: iteration.submission.tests_status,
      automated_feedback_status: iteration.automated_feedback_status.to_s,
      automated_feedback: iteration.automated_feedback,
      links: {
        self: Exercism::Routes.track_exercise_iterations_url(iteration.track, iteration.exercise, idx: iteration.idx)
      }
    }
  end
end
