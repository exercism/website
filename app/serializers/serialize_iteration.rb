class SerializeIteration
  include Mandate

  initialize_with :iteration, sideload: []

  def call
    return if iteration.blank?
    return deleted_version if iteration.deleted?

    {
      uuid: iteration.uuid,
      submission_uuid: iteration.submission.uuid,
      idx: iteration.idx,
      status: iteration.status.to_s,
      num_essential_automated_comments: iteration.num_essential_automated_comments,
      num_actionable_automated_comments: iteration.num_actionable_automated_comments,
      num_non_actionable_automated_comments: iteration.num_non_actionable_automated_comments,
      num_celebratory_automated_comments: iteration.num_celebratory_automated_comments,
      submission_method: iteration.submission.submitted_via,
      created_at: iteration.created_at.iso8601,
      tests_status: iteration.submission.tests_status,
      representer_feedback: sideload.include?(:automated_feedback) ? iteration.representer_feedback : nil,
      analyzer_feedback: sideload.include?(:automated_feedback) ? iteration.analyzer_feedback : nil,
      is_published: iteration.published?,
      is_latest: iteration.latest?,
      files: sideload.include?(:files) ? iteration.files.map do |file|
        {
          filename: file.filename,
          content: file.content,
          digest: file.digest
        }
      end : nil,
      # The page links are never locale-prefixed. Only the iteration's owner
      # follows them, and a signed-in user's URLs carry no prefix. That also
      # keeps the community solution payload, which is cached once for
      # everyone (Solution::CachedSerializedView::Retrieve), locale-free.
      links: {
        self: Exercism::Routes.track_exercise_iterations_url(iteration.track, iteration.exercise, idx: iteration.idx, locale: nil),
        automated_feedback: Exercism::Routes.automated_feedback_api_solution_iteration_url(iteration.solution.uuid, iteration.uuid),
        delete: Exercism::Routes.api_solution_iteration_url(iteration.solution.uuid, iteration.uuid),
        solution: Exercism::Routes.track_exercise_url(iteration.track, iteration.exercise, locale: nil),
        test_run: Exercism::Routes.api_solution_submission_test_run_url(iteration.solution.uuid, iteration.submission.uuid),
        files: Exercism::Routes.api_solution_submission_files_url(iteration.solution.uuid, iteration.submission)
      }
    }.compact
  end

  private
  def deleted_version
    {
      uuid: iteration.uuid,
      idx: iteration.idx,
      status: 'deleted',
      num_essential_automated_comments: 0,
      num_actionable_automated_comments: 0,
      num_non_actionable_automated_comments: 0,
      num_celebratory_automated_comments: 0,
      submission_method: iteration.submission.submitted_via,
      created_at: iteration.created_at.iso8601,
      tests_status: 'not_queued',
      representer_feedback: 'not_queued',
      analyzer_feedback: 'not_queued',
      is_published: false,
      files: sideload.include?(:files) ? [] : nil,
      links: {
        self: Exercism::Routes.track_exercise_iterations_url(iteration.track, iteration.exercise, idx: iteration.idx, locale: nil),
        solution: Exercism::Routes.track_exercise_url(iteration.track, iteration.exercise, locale: nil)
      }
    }.compact
  end
end
