class AddLastSubmittedAtToExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_column :exercise_representations, :last_submitted_at, :datetime, null: false, default: Time.now, if_not_exists: true

    unless Rails.env.production?
      Exercise::Representation.find_each do |rep|
        rep.update(last_submitted_at: rep.submission_representations.last.created_at)
      end
    end
  end
end
