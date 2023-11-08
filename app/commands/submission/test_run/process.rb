class Submission::TestRun::Process
  include Mandate

  initialize_with :tooling_job

  def call
    # This goes in its own transaction. We want
    # to record this whatever happens.
    test_run = submission.test_runs.create!(
      tooling_job_id: tooling_job.id,
      ops_status: tooling_job.execution_status.to_i,
      raw_results: results,
      git_sha:
    )

    # Then all of the submethods here should
    # action within transaction setting the
    # status to be an error if it fails.
    begin
      if test_run.ops_errored?
        handle_ops_error!
      elsif test_run.passed?
        handle_pass!
      elsif test_run.failed?
        handle_fail!
      elsif test_run.errored?
        handle_error!
      else
        raise "Unknown status"
      end
    rescue StandardError => e
      # Alert bugsnag and mark as exceptioned
      Bugsnag.notify(e)
      update_status!(:exceptioned)
    end

    broadcast!(test_run)
  end

  private
  delegate :solution, :exercise, to: :submission

  def handle_ops_error!
    update_status!(:exceptioned)
  end

  def handle_pass!
    update_status!(:passed)
  end

  def handle_fail!
    update_status!(:failed)
    cancel_other_services!
  end

  def handle_error!
    update_status!(:errored)
    cancel_other_services!
  end

  def cancel_other_services!
    return unless submission_test_run?

    ToolingJob::Cancel.(submission.uuid, :analyzer)
    ToolingJob::Cancel.(submission.uuid, :representer)
  end

  def update_status!(status)
    update_submission_status!(status)
    update_solution_status!
  end

  def update_submission_status!(status)
    # If this is not relevant to the submission, leave it alone
    return unless submission_test_run?

    submission.with_lock do
      return if submission.tests_cancelled?

      submission.send("tests_#{status}!")

      representation = submission.exercise_representation
      Exercise::Representation::UpdateNumSubmissions.defer(representation) if representation
    end
  end

  def update_solution_status!
    # All the logic about whether we should do this etc is encapsulated
    # into the two downstream commands, so we can just proxy to them and
    # leave them to work it all out.
    Solution::SyncPublishedIterationHeadTestsStatus.(solution)
    Solution::SyncLatestIterationHeadTestsStatus.(solution)
  end

  def broadcast!(test_run)
    return unless submission_test_run?

    # Work through and process the test run
    # then before broadcasting, check whether it's been
    # cancelled, and update it if so.
    # This whole bit is very racey so the order is very
    # important to consider.
    if submission.tests_cancelled?
      test_run.update!(status: "cancelled")
      return
    end

    submission.broadcast!
    submission.iteration&.broadcast!
    test_run.broadcast!
  end

  memoize
  def results
    res = JSON.parse(tooling_job.execution_output['results.json'], allow_invalid_unicode: true)
    res.is_a?(Hash) ? res.symbolize_keys : {}
  rescue StandardError => e
    Bugsnag.notify(e)
    {}
  end

  memoize
  def submission
    Submission.find_by!(uuid: tooling_job.submission_uuid)
  end

  # This method determines whether this test run is actually
  # relevant to this submission, or if we've just run other tests against
  # this submission.
  memoize
  def submission_test_run?
    submission.git_sha == git_sha
  end

  memoize
  def git_important_files_hash
    Git::GenerateHashForImportantExerciseFiles.(exercise, git_sha:)
  end

  memoize
  def git_sha
    tooling_job.source["exercise_git_sha"]
  end
end
