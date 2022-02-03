class AddPublishedIterationHeadTestsStatusToSolutions < ActiveRecord::Migration[7.0]
  def up
    execute "ALTER TABLE `solutions` ADD `published_iteration_head_tests_status` integer(2) DEFAULT 0 NOT NULL, ALGORITHM=INPLACE, LOCK=NONE"
  end

  def down
    remove_column :solutions, :published_iteration_head_tests_status
  end
end
