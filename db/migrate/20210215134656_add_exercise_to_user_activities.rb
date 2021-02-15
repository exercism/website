class AddExerciseToUserActivities < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :user_activities, :exercise, null: true, foreign_key: true
  end
end
