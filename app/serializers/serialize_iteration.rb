class SerializeIteration
  include Mandate

  initialize_with :iteration

  def call
    {
      id: iteration.id,
      idx: iteration.idx,
      submission_method: iteration.submission.submitted_via,
      created_at: iteration.created_at.iso8601,
      tests_status: iteration.submission.tests_status,
      representation_status: iteration.submission.representation_status,
      analysis_status: iteration.submission.analysis_status,
      links: {
        self: Exercism::Routes.track_exercise_iterations_url(iteration.track, iteration.exercise, idx: iteration.idx)
      }
    }
  end
end
