class AddGitImportantFilesHashToSolutionsAndExercises < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :git_important_files_hash, :string, null: true
    add_column :exercises, :git_important_files_hash, :string, null: true

    Exercise.find_each do |exercise|
      exercise.update!(git_important_files_hash: Git::GenerateHashForImportantExerciseFiles.(exercise))      
    end

    Solution.find_each do |solution|
      solution.update!(
        git_slug: exercise.slug,
        git_sha: exercise.git_sha,
        git_important_files_hash: exercise.git_important_files_hash)      
    end

    change_column_null :solutions, :git_important_files_hash, :false
    change_column_null :exercises, :git_important_files_hash, :false
  end
end
