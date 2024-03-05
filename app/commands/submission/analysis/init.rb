class Submission::Analysis::Init
  include Mandate

  initialize_with :submission, run_in_background: false

  def call
    return unless exercise.has_analyzer?

    ToolingJob::Create.(
      submission, :analyzer,
      run_in_background:
    )
    submission.analysis_queued!
  end

  delegate :exercise, to: :submission
end
