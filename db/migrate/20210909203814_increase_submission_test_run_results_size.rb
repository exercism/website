class IncreaseSubmissionTestRunResultsSize < ActiveRecord::Migration[6.1]
  def change
    change_column :submission_test_runs, :raw_results, :text, size: :medium
  end
end
