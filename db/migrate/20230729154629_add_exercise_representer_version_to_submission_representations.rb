class AddExerciseRepresenterVersionToSubmissionRepresentations < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :submissions, :exercise_representer_version, :smallint, null: false, default: 1
    add_column :submission_representations, :exercise_representer_version, :smallint, null: false, default: 1
  end
end
