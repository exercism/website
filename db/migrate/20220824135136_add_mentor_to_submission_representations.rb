class AddMentorToSubmissionRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_reference :submission_representations, :mentor, null: true, foreign_key: { to_table: :users }, if_not_exists: true

    unless Rails.env.production?
      # TODO: add migration
      # Submission::Representation.find_each do |representation|
      #   representation
      # end      
    end
  end
end
