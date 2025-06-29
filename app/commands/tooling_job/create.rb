class ToolingJob::Create
  include Mandate

  def initialize(submission, type, git_sha: nil, run_in_background: false, context: {})
    @submission = submission
    @type = type.to_sym
    @git_sha = git_sha || submission.git_sha
    @run_in_background = !!run_in_background
    @context = context
  end

  def call
    ToolingJob::UploadToEFS.(efs_dir, submission.files)

    # Deal with redis sometimes being having network spike issue
    @num_attempts = 0
    begin
      Exercism::ToolingJob.create!(
        job_id,
        type,
        submission.uuid,
        efs_dir,
        solution.track.slug,
        solution.exercise.slug,
        run_in_background:,
        source: {
          submission_efs_root: efs_dir,
          submission_filepaths: valid_filepaths,
          exercise_git_repo: solution.track.slug,
          exercise_git_sha: git_sha,
          exercise_git_dir: exercise_repo.dir,
          exercise_filepaths:
        },
        context:
      )
    rescue Redis::Cluster::InitialSetupError => e
      @num_attempts += 1
      raise e if @num_attempts > 5

      sleep(1)
      retry
    end
  end

  private
  attr_reader :submission, :git_sha, :type, :run_in_background, :context

  memoize
  delegate :solution, to: :submission

  memoize
  def job_id = SecureRandom.uuid.tr('-', '')

  memoize
  def efs_dir
    date = Time.current.utc.strftime('%Y/%m/%d')
    "#{Exercism.config.efs_tooling_jobs_mount_point}/#{date}/#{job_id}"
  end

  def exercise_filepaths
    exercise_repo.tooling_filepaths.reject do |filepath|
      valid_filepaths.include?(filepath)
    end
  end

  def valid_filepaths
    submission.valid_filepaths(exercise_repo)
  end

  memoize
  def exercise_repo
    Git::Exercise.new(
      solution.git_slug,
      solution.git_type,
      git_sha,
      repo_url: solution.track.repo_url
    )
  end
end
