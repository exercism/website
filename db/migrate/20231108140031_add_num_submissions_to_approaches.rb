class AddNumSubmissionsToApproaches < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :exercise_approaches, :num_solutions, :integer, null: false, default: 0
  end
end
