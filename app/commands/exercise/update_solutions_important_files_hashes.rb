class Exercise
  # This is a manual command that should be manually when the important files hash
  # calculation algorithm has been updated and the important files hash thus
  # must be re-calculated
  class UpdateSolutionsImportantFilesHashes
    include Mandate

    initialize_with :exercise, :old_hash, :new_hash

    def call
      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        # We use loop here and for the things below to avoid locking millions of records
        # We just keep going until we run out of records to update.
        loop do
          num_results = Solution.where(exercise:, git_important_files_hash: old_hash).
            limit(BATCH_UPDATE_SIZE).
            update_all(git_important_files_hash: new_hash)
          break if num_results < BATCH_UPDATE_SIZE
        end

        loop do
          num_results = Submission.where(exercise:, git_important_files_hash: old_hash).
            limit(BATCH_UPDATE_SIZE).
            update_all(git_important_files_hash: new_hash)
          break if num_results < BATCH_UPDATE_SIZE
        end

        loop do
          num_results = Submission::TestRun.joins(:submission).where(submissions: { exercise: },
            git_important_files_hash: old_hash).
            limit(BATCH_UPDATE_SIZE).
            update_all(git_important_files_hash: new_hash)
          break if num_results < BATCH_UPDATE_SIZE
        end
      end
    end

    BATCH_UPDATE_SIZE = 1_000
    private_constant :BATCH_UPDATE_SIZE
  end
end
