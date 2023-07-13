class AddIndexesForUpdating < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :solutions, [:exercise_id, :git_important_files_hash]
    add_index :submissions, [:exercise_id, :git_important_files_hash]
    add_index :submission_test_runs, [:submission_id, :git_important_files_hash], name: "index_submission_test_run_on_submission_id_and_gifh"
    add_index :submission_test_runs, [:git_important_files_hash]
  end
end
