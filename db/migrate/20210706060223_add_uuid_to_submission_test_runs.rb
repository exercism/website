class AddUuidToSubmissionTestRuns < ActiveRecord::Migration[6.1]
  def change
    add_column :submission_test_runs, :uuid, :string, null: false

    add_index :submission_test_runs, :uuid, unique: true
  end
end
