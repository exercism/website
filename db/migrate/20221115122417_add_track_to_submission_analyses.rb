class AddTrackToSubmissionAnalyses < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_reference :submission_analyses, :track, null: true, foreign_key: true, if_not_exists: true
      add_index :submission_analyses, %i[track_id id], order: {track_id: :asc, id: :desc}, unique: false, if_not_exists: true

      Submission::Analysis.includes(submission: :track).find_in_batches do |batch|
        ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
          batch.each do |analysis|
            analysis.update(track_id: analysis.submission.track&.id)
          end
        end
      end
    end
  end
end
