class AddTagsToExerciseApproaches < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :exercise_approaches, :tags, :json, null: true
  end
end
