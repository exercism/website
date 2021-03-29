class AddVersionToTestRun < ActiveRecord::Migration[6.1]
  def change
    # TODO: What should the default be?
    add_column :submission_test_runs, :version, :tinyint, default: 0, null: false
    remove_column :submission_test_runs, :tests
  end
end
