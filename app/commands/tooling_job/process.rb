class ToolingJob::Process
  class AlreadyProcessedJobError < RuntimeError
  end

  include Mandate

  initialize_with :id

  def call
    send("process_#{job.type}_job!")
    job.processed!
  rescue AlreadyProcessedJobError
    # We can silently ignore this
  end

  private
  def process_test_runner_job!
    guard_duplicate!(Submission::TestRun)

    Submission::TestRun::Process.(job)
  end

  def process_representer_job!
    guard_duplicate!(Submission::Representation)

    Submission::Representation::Process.(job)
  end

  def process_analyzer_job!
    guard_duplicate!(Submission::Analysis)

    Submission::Analysis::Process.(job)
  end

  def guard_duplicate!(klass)
    raise AlreadyProcessedJobError if klass.where(tooling_job_id: job.id).exists?
  end

  memoize
  def job
    Exercism::ToolingJob.find(id)
  end
end
