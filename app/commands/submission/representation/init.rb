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
    # Set the status before queueing the job, so that the
    # job's result can't be overwritten if it runs quickly.
    update_status!
    job_class.defer(submission, git_sha, reason:)
  end

  private
  attr_reader :submission, :type, :git_sha, :run_in_background

  def job_class
    run_in_background ? Submission::Representation::Generate::InBackground : Submission::Representation::Generate
  end

  def update_status!
    return if type == :exercise

    submission.representation_queued!
  end

  def reason = type == :exercise ? :update : nil
end
