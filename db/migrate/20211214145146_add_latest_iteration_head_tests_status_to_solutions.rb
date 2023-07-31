class AddLatestIterationHeadTestsStatusToSolutions < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :latest_iteration_head_tests_status, :tinyint, default: 0, null: false, if_not_exists: true
  end
end
