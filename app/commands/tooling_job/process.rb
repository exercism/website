class ToolingJob::Process
  include Mandate

  initialize_with :id

  def call
    send("process_#{job.type}_job!")
    job.processed!
  end

  private
  def process_test_runner_job!
    Submission::TestRun::Process.(job)
  end

  def process_representer_job!
    Submission::Representation::Process.(job)
  end

  def process_analyzer_job!
    Submission::Analysis::Process.(job)
  end

  memoize
  def job
    Exercism::ToolingJob.find(id)
  end
end
