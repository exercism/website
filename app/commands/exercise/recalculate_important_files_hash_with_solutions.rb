class Exercise
  # This is a manual command that should be manually when the important files hash
  # calculation algorithm has been updated and the important files hash thus
  # must be re-calculated
  class RecalculateImportantFilesHashWithSolutions
    include Mandate

    initialize_with :exercise

    def call
      return if new_git_important_files_hash == old_git_important_files_hash

      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        exercise.update!(git_important_files_hash: new_git_important_files_hash)

        # We're calling this explicitely here, but do we need to?
        # Does it not implicitely get called anyway? Let's double check
        # before running this command again!
        UpdateSolutionGitData.(exercise, old_git_important_files_hash)
      end
    end

    private
    memoize
    def new_git_important_files_hash
      Git::GenerateHashForImportantExerciseFiles.(exercise)
    end

    memoize
    def old_git_important_files_hash
      exercise.git_important_files_hash
    end
  end
end
