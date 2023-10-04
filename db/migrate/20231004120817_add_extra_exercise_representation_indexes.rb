class AddExtraExerciseRepresentationIndexes < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :exercise_representations, [:track_id, :representer_version], order: {representer_version: :desc}, name: "index_exercise_representations_track_version_desc"

    add_index :exercise_representations, [:track_id, :representer_version, :num_submissions], order: {representer_version: :desc, num_submissions: :desc}, name: "search_track_1"
    add_index :exercise_representations, [:track_id, :representer_version, :feedback_type, :num_submissions], order: {representer_version: :desc, num_submissions: :desc}, name: "search_track_2"
    add_index :exercise_representations, [:track_id, :representer_version, :last_submitted_at], order: {representer_version: :desc, last_submitted_at: :desc}, name: "search_track_3"
    add_index :exercise_representations, [:track_id, :representer_version, :feedback_added_at], order: {representer_version: :desc, feedback_added_at: :desc}, name: "search_track_4"
    add_index :exercise_representations, [:track_id, :representer_version, :feedback_added_at], order: {representer_version: :desc}, name: "search_track_5"

    add_index :exercise_representations, [:exercise_id, :representer_version, :num_submissions], order: {representer_version: :desc}, name: "search_ex_1"
    add_index :exercise_representations, [:exercise_id, :representer_version, :num_submissions, :last_submitted_at], order: {representer_version: :desc, last_submitted_at: :desc}, name: "search_ex_2"
    add_index :exercise_representations, [:exercise_id, :representer_version, :last_submitted_at], order: {representer_version: :desc, last_submitted_at: :desc}, name: "search_ex_3"
    add_index :exercise_representations, [:exercise_id, :representer_version, :feedback_added_at], order: {representer_version: :desc, feedback_added_at: :desc}, name: "search_ex_4"
    add_index :exercise_representations, [:exercise_id, :representer_version, :feedback_added_at], order: {representer_version: :desc}, name: "search_ex_5"
  end
end
