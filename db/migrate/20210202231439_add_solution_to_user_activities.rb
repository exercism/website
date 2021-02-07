class AddSolutionToUserActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :user_activities, :solution_id, :bigint, null: true, foreign_key: true
    remove_column :user_activities, :grouping_key
  end
end
