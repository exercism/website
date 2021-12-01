class AddPublishedIterationHeadTestsStatusToSolutions < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :published_iteration_head_tests_status, :integer, null: false, default: 0
  end
end
