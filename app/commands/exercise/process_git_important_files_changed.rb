class Exercise::ProcessGitImportantFilesChanged
  include Mandate

  initialize_with :exercise, :old_git_important_files_hash, :old_sha, :old_slug

  # We are calling this file because the git important hash of an exercise has changed.
  # That means that some important files have changed. Depending on which files, and
  # whether the maintainer has set different flags, we need to set different behaviours.
  #
  # There are two scenarios.
  # 1. The changes *could* affect the test outcome of solutions to this exercise.
  #    We need to re-run the tests for these solutions.
  # 2. The changes *can't* (or shouldn't) affect the test outcome.
  #    We don't need to re-run any tests.
  #
  # The first scenario only applies when the following things are all true:
  # 1. The exercise's `git_important_files_hash` has changed.
  # 2. The commit has changed files that could influence the test results.
  #    Changes to documentation *don't count*, as they won't influence any
  #    test results, but changes to test files *do* count.
  # 3. The commit does *not* include the flag that says: "although it looks
  #    like things have changed, they haven't really". Maintainers can add
  #    this flag to when they know a change won't influence the test result,
  #    such as only whitespace or grammar changes being applied.
  #
  # When none of the above is true, we won't re-run any tests.
  def call
    if tests_need_rerunning?
      # First we mark all solutions as out of date in the index.
      # We want it to run before we go through and reprocess all
      # the head test runs. It should be fast, so we do it in-band here.
      Exercise::MarkSolutionsAsOutOfDateInIndex.(exercise)

      # Then we queue up all the solution head test runs, which could
      # potentially take a long time
      Exercise::QueueSolutionHeadTestRuns.defer(exercise)
    else
      # If the tests don't need rerunning, we want to update everything that
      # had the old hash to have the new one. Effectively we say the old hash
      # never existed and that it's always been the new one!
      Exercise::UpdateSolutionGitData.(exercise, old_git_important_files_hash)
    end
  end

  private
  def tests_need_rerunning?
    return false if old_git_important_files_hash == exercise.git_important_files_hash

    # If the maintainer has used the manual flag, then
    # don't run anything here
    return false if exercise.git_no_important_files_changed?

    # We only re-run the tests if any testable files were changed.
    # If only documentation or irrelevant files were changed, we don't
    # need to re-run the tests as their end result would be the same
    Git::Exercise::CheckForTestableChangesBetweenVersions.(exercise, old_slug, old_sha)
  end
end
