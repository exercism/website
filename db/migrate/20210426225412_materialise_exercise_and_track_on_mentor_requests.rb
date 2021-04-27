class MaterialiseExerciseAndTrackOnMentorRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :mentor_requests, :track_id, :bigint
    add_column :mentor_requests, :exercise_id, :bigint
    add_column :mentor_requests, :student_id, :bigint

    Mentor::Request.joins(solution: :exercise).update_all("mentor_requests.track_id = exercises.track_id")
    Mentor::Request.joins(:solution).update_all("mentor_requests.exercise_id = solutions.exercise_id")
    Mentor::Request.joins(:solution).update_all("mentor_requests.student_id = solutions.user_id")

    change_column_null :mentor_requests, :track_id, false
    change_column_null :mentor_requests, :exercise_id, false
    change_column_null :mentor_requests, :student_id, false

    ActiveRecord::Base.connection.add_index :mentor_requests, [:status, :track_id]
    ActiveRecord::Base.connection.add_index :mentor_requests, [:status, :exercise_id]
  end
end
