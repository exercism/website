class AddNumSubmissionsToRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_column :exercise_representations, :num_submissions, :integer, null: false, default: 1, if_not_exists: true
  end
end
