class Exercise
  class ProcessGitImportantFilesChanged
    include Mandate

    initialize_with :exercise, :old_git_important_files_hash

    # We are calling this file because the git important hash of an exercise has changed.
    # That means that some important files have changed. Depending on which files, and
    # whether the maintainer has set different flags, we need to set different behaviours.
    #
    # There are two scenarios.
    # 1. The first is that the testable files have changed (e.g. the tests or
    #    some build file). In this sceneario, we need to rerun all the tests and
    #    mark things out of date.
    # 2. Things haven't changed, either because only the docs have changed,
    #    or because
    def call
      # Maintainers can specify a flag that says "although it looks like things have
      # changed, they haven't really". This is used for example when the file only contains
      # whitespace changes, or grammar changes.
      # The same situation applies if only documentation has changed.
      # In thse scenearios, we want to update all the solution files to just have the
      # new hash and do nothing else. The user will never know anything has happened.
      unless tests_need_rerunning?
        UpdateSolutionGitData.(exercise, old_git_important_files_hash)
        return
      end

      # In other scenarios, we do need to retest everything, and also update the
      # indexes to mark things out of date.

      # Firstly we run this. We want it to run before we go through
      # and reprocess all the head test runs, and it should be fast.
      # So we do it in bands here.
      Exercise::MarkSolutionsAsOutOfDateInIndex.(exercise)

      # Then we queue up all the solution head test runs
      Exercise::QueueSolutionHeadTestRuns.defer(exercise)
    end

    private
    def tests_need_rerunning?
      return false if old_git_important_files_hash == exercise.git_important_files_hash

      # If the maintainer has used the manual flag, then
      # don't run anything here
      return false if exercise.git_no_important_files_changed?

      # TODO: Guard against just documentation changes

      true
    end
  end
end
