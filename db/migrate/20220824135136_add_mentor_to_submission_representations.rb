class AddMentorToSubmissionRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_reference :submission_representations, :mentor, null: true, foreign_key: { to_table: :users }, if_not_exists: true

    unless Rails.env.production?
      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        Submission::Representation.includes(submission: %i[solution iteration]).find_each do |representation|
          Submission::Representation::UpdateMentor.(representation.submission)
        end
      end
    end
  end
end
