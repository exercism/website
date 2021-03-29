class AddOutputToTestRuns < ActiveRecord::Migration[6.1]
  def change
    add_column :submission_test_runs, :output, :text
  end
end
