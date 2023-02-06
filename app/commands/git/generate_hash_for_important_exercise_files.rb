class Git::GenerateHashForImportantExerciseFiles
  include Mandate

  def initialize(exercise, git_sha: nil)
    @exercise = exercise
    @git_sha = git_sha || exercise.git_sha
  end

  def call
    Digest::SHA1.hexdigest(git_exercise.important_files.map { |_, contents| contents }.join)
  end

  private
  def git_exercise
    # We recreate the Git::Exercise instead of using the exercise's `git` property
    # as the latter is memoized and might point to an older git sha
    Git::Exercise.new(exercise.slug, exercise.git_type, git_sha, repo_url: exercise.track.repo_url)
  end

  attr_reader :exercise, :git_sha
end
