class Git::Exercise::CheckForTestableChangesBetweenVersions
  include Mandate

  initialize_with :exercise, :old_slug, :old_sha

  def call
    diff_files = diff.map { |di| di[:relative_path] }
    testable_files = (diff_files & git_exercise.important_filepaths) - docs_filepaths
    testable_files.present?
  rescue Git::MissingCommitError, Rugged::TreeError
    # If we can't find the old commit, then we presume that things have
    # changed so dramatically that they definitely need testing!
    true
  end

  private
  memoize
  def diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, old_slug, old_sha)

  memoize
  def docs_filepaths
    [
      git_exercise.instructions_filepath,
      git_exercise.instructions_append_filepath,
      git_exercise.introduction_filepath,
      git_exercise.introduction_append_filepath,
      git_exercise.hints_filepath
    ]
  end

  memoize
  def git_exercise = exercise.git
end
