class AddIndexesToExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_index :exercise_representations, %i[feedback_type track_id num_submissions], order: {feedback_type: :asc, track_id: :asc, num_submissions: :desc}, unique: false, name: 'index_exercise_representation_type_track_num_submissions', if_not_exists: true
    add_index :exercise_representations, %i[feedback_type track_id last_submitted_at], order: {feedback_type: :asc, track_id: :asc, last_submitted_at: :desc}, unique: false, name: 'index_exercise_representation_type_track_last_submitted_at', if_not_exists: true
    add_index :exercise_representations, %i[feedback_author_id track_id num_submissions], order: {feedback_author_id: :asc, track_id: :asc, num_submissions: :desc}, unique: false, name: 'index_exercise_representation_author_track_num_submissions', if_not_exists: true
    add_index :exercise_representations, %i[feedback_author_id track_id last_submitted_at], order: {feedback_author_id: :asc, track_id: :asc, last_submitted_at: :desc}, unique: false, name: 'index_exercise_representation_author_track_last_submitted_at', if_not_exists: true

    add_index :exercise_representations, %i[feedback_type exercise_id num_submissions], order: {feedback_type: :asc, exercise_id: :asc, num_submissions: :desc}, unique: false, name: 'index_exercise_representation_type_exercise_num_submissions', if_not_exists: true
    add_index :exercise_representations, %i[feedback_type exercise_id last_submitted_at], order: {feedback_type: :asc, exercise_id: :asc, last_submitted_at: :desc}, unique: false, name: 'index_exercise_representation_type_exercise_last_submitted_at', if_not_exists: true
    add_index :exercise_representations, %i[feedback_author_id exercise_id num_submissions], order: {feedback_author_id: :asc, exercise_id: :asc, num_submissions: :desc}, unique: false, name: 'index_exercise_representation_author_exercise_num_submissions', if_not_exists: true
    add_index :exercise_representations, %i[feedback_author_id exercise_id last_submitted_at], order: {feedback_author_id: :asc, exercise_id: :asc, last_submitted_at: :desc}, unique: false, name: 'index_exercise_representation_author_exercise_last_submitted_at', if_not_exists: true
  end
end
