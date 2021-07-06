class AddUuidToSubmissionTestRuns < ActiveRecord::Migration[6.1]
  def change
    add_column :submission_test_runs, :uuid, :string, null: true
    Submission::TestRun.update_all("`uuid` = UUID()")
    change_column_null :submission_test_runs, :uuid, false
    add_index :submission_test_runs, :uuid, unique: true
  end
end
