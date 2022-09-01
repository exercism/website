class AddLastSubmittedAtToExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_column :exercise_representations, :last_submitted_at, :datetime, null: false, default: -> { 'NOW(6)' }, if_not_exists: true

    unless Rails.env.production?
      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        Exercise::Representation.find_each do |representation|
          Exercise::Representation
            .where(id: representation.id)
            .update_all(last_submitted_at: representation.submission_representations.last.created_at)
        end
      end
    end
  end
end
