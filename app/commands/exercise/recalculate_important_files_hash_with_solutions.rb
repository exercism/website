class Exercise
  # This command should be called manually when the important files hash
  # calculation algorithm has been updated and the important files hash thus
  # must be re-calculated
  class RecalculateImportantFilesHashWithSolutions
    include Mandate

    initialize_with :exercise

    def call
      return if new_git_important_files_hash == old_git_important_files_hash

      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        exercise.update!(git_important_files_hash: new_git_important_files_hash)

        # We use loop here and for the things below to avoid locking millions of records
        # We just keep going until we run out of records to update.
        loop do
          num_results = Solution.where(exercise:, git_important_files_hash: old_git_important_files_hash).
            limit(BATCH_UPDATE_SIZE).
            update_all(git_important_files_hash: new_git_important_files_hash)
          break if num_results < BATCH_UPDATE_SIZE
        end

        loop do
          num_results = Submission.where(exercise:, git_important_files_hash: old_git_important_files_hash).
            limit(BATCH_UPDATE_SIZE).
            update_all(git_important_files_hash: new_git_important_files_hash)
          break if num_results < BATCH_UPDATE_SIZE
        end

        loop do
          num_results = Submission::TestRun.joins(:submission).where(submissions: { exercise: },
            git_important_files_hash: old_git_important_files_hash).
            limit(BATCH_UPDATE_SIZE).
            update_all(git_important_files_hash: new_git_important_files_hash)
          break if num_results < BATCH_UPDATE_SIZE
        end
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

    BATCH_UPDATE_SIZE = 1_000
    private_constant :BATCH_UPDATE_SIZE
  end
end
