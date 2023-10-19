class Submission::Analysis::Init
  include Mandate

  initialize_with :submission, run_in_background: false

  def call
    ToolingJob::Create.(
      submission, :analyzer,
      run_in_background:
    )
    submission.analysis_queued!
  end
end
