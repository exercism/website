class Submission::Analysis::Init
  include Mandate

  initialize_with :submission

  def call
    ToolingJob::Create.(submission, :analyzer)
    submission.analysis_queued!
  end
end
