class AddFeedbackAddedAtToExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_column :exercise_representations, :feedback_added_at, :datetime, null: true, if_not_exists: true

    unless Rails.env.production?
      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        Exercise::Representation
          .where.not(feedback_type: nil)
          .update_all('feedback_added_at = updated_at')
      end
    end
  end
end
