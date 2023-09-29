# This syncs submission's test status to the results of its latest test_run
class Submission::SyncTestsStatus
  include Mandate

  initialize_with :submission

  def call
    return false unless test_run

    if test_run.ops_errored?
      status = :exceptioned
    elsif test_run.passed?
      status = :passed
    elsif test_run.failed?
      status = :failed
    else
      status = :errored
    end

    # This will often be a noop
    submission.update!(tests_status: status)
    true
  end

  # Get this afresh from the database - don't use reload etc
  memoize
  def test_run = Submission::TestRun.for!(submission)
end
