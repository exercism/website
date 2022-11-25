class AddExerciseToSubmissions < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :submissions, :exercise_id, :mediumint, null: true
      add_index :submissions, %i[track_id exercise_id], unique: false, if_not_exists: true

      Submission.includes(:solution).find_in_batches do |batch|
        ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
          batch.each do |submission|
            submission.update_column(:exercise_id, submission.solution.exercise_id)
          end
        end
      end
    end
  end
end
