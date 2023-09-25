class Submission::Representation::Init
  include Mandate

  def initialize(submission, type: :submission, git_sha: nil, run_in_background: false)
    raise unless %i[submission exercise].include?(type)

    @submission = submission
    @type = type.to_sym
    @git_sha = git_sha || submission.git_sha
    @run_in_background = !!run_in_background
  end

  def call
    queue_job!.tap do
      update_status!
    end
  end

  private
  attr_reader :submission, :type, :git_sha, :run_in_background

  def queue_job!
    return Submission::Representation::GenerateBasic.defer(submission) unless track.has_representer?

    ToolingJob::Create.(
      submission,
      :representer,
      git_sha:,
      run_in_background:,
      context:
    )
  end

  delegate :track, to: :submission

  def update_status!
    return if type == :exercise

    submission.representation_queued!
  end

  def context
    type == :exercise ? { reason: :update } : {}
  end
end
