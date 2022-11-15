class AddTrackToSubmissionRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_reference :submission_representations, :track, null: true, foreign_key: true, if_not_exists: true
    add_index :submission_representations, %i[track_id id], order: {track_id: :asc, id: :desc}, unique: false, if_not_exists: true

    unless Rails.env.production?
      Submission::Representation.includes(submission: :track).find_in_batches do |batch|
        batch.each do |representation|
          representation.update(track_id: representation.submission.track.id)
        end
      end
    end
  end
end
