class MaterializeStatusColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :tracks, :course, :boolean, null: false, default: false
    add_column :tracks, :has_test_runner, :boolean, null: false, default: false
    add_column :exercises, :has_test_runner, :boolean, null: false, default: false

    Track.find_each do |track|
      track.update(
         has_test_runner: track.git.has_test_runner?,
         course: track.git.has_concept_exercises?,
      )
    end

    Exercise.find_each do |exercise|
      exercise.update(
         has_test_runner: exercise.git.has_test_runner?,
      )
    end
  end
end
