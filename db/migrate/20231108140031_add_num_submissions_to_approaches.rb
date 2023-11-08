class AddNumSubmissionsToApproaches < ActiveRecord::Migration[7.0]
  def change
    add_column :exercise_approaches, :num_submissions, :integer, null: false, default: 0
  end
end
