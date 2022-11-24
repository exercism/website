class AddBuildStatusIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :mentor_requests, %i[track_id exercise_id]
  end
end
