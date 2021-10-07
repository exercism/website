class Exercise
  class UpdateHashForImportantExerciseFiles
    include Mandate

    initialize_with :exercise

    def call
      return if new_git_important_files_hash == old_git_important_files_hash

      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        exercise.update!(git_important_files_hash: new_git_important_files_hash)
        exercise.solutions.where(git_important_files_hash: old_git_important_files_hash).
          update_all(git_important_files_hash: new_git_important_files_hash)
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
