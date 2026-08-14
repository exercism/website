class ToolingJob::Process
  include Mandate

  initialize_with :id

  def call
    # This is deferred because it's cleanup rather than part of processing -
    # nothing below reads from EFS. It's an rm_rf over NFS, so every file is a
    # network round trip, and there's no reason for the request to wait for it.
    ToolingJob::DeleteFromEFS.defer(job.efs_dir)

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
