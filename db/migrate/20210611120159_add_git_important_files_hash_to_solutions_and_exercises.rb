class AddGitImportantFilesHashToSolutionsAndExercises < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :git_important_files_hash, :string, null: true
    add_column :exercises, :git_important_files_hash, :string, null: true

    # TODO: populate column values

    # TODO: re-enable
    # change_column_null :solutions, :git_important_files_hash, :false
    # change_column_null :exercises, :git_important_files_hash, :false
  end
end
