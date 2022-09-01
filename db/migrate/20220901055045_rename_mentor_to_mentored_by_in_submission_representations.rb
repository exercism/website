class RenameMentorToMentoredByInSubmissionRepresentations < ActiveRecord::Migration[7.0]
  def change
    rename_column :submission_representations, :mentor_id, :mentored_by_id

    unless Rails.env.production?
      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        Submission::Representation.includes(submission: %i[solution iteration]).find_each do |representation|
          Submission::Representation::UpdateMentor.(representation.submission)
        end
      end
    end
  end
end
