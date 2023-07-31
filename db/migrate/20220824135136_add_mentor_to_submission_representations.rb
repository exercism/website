class AddMentorToSubmissionRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_reference :submission_representations, :mentor, null: true, foreign_key: { to_table: :users }, if_not_exists: true
  end
end
