class Exercise
  class UpdateSolutionGitData
    include Mandate

    initialize_with :exercise, :old_git_important_files_hash

    def call
      # We use loop here and for the things below to avoid locking millions of records
      # We just keep going until we run out of records to update.
      loop do
        ids = Solution.where(exercise:, git_important_files_hash: old_git_important_files_hash).
          limit(BATCH_UPDATE_SIZE).pluck(:id)

        Solution.where(id: ids).update_all(
          git_sha: new_git_sha,
          git_slug: new_git_slug,
          git_important_files_hash: new_git_important_files_hash,
          updated_at: Time.current
        )
        break if ids.length < BATCH_UPDATE_SIZE
      end

      loop do
        ids = Submission.where(exercise:, git_important_files_hash: old_git_important_files_hash).
          limit(BATCH_UPDATE_SIZE).pluck(:id)

        Submission.where(id: ids).update_all(
          git_sha: new_git_sha,
          git_slug: new_git_slug,
          git_important_files_hash: new_git_important_files_hash,
          updated_at: Time.current
        )
        break if ids.length < BATCH_UPDATE_SIZE
      end

      loop do
        ids = Submission::TestRun.joins(:submission).where(submissions: { exercise: },
          git_important_files_hash: old_git_important_files_hash).
          limit(BATCH_UPDATE_SIZE).pluck(:id)

        Submission::TestRun.where(id: ids).update_all(
          git_sha: new_git_sha,
          git_important_files_hash: new_git_important_files_hash,
          updated_at: Time.current
        )
        break if ids.length < BATCH_UPDATE_SIZE
      end
    end

    BATCH_UPDATE_SIZE = 1_000
    private_constant :BATCH_UPDATE_SIZE

    memoize
    def new_git_sha = exercise.git_sha

    memoize
    def new_git_slug = exercise.slug

    memoize
    def new_git_important_files_hash = exercise.git_important_files_hash
  end
end
