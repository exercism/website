class AddTrackToSubmissionTestRuns < ActiveRecord::Migration[7.0]
  def change
    add_reference :submission_test_runs, :track, null: true, foreign_key: true, if_not_exists: true
    add_index :submission_test_runs, %i[track_id id], order: {track_id: :asc, id: :desc}, unique: false, if_not_exists: true

    unless Rails.env.production?
      Submission::TestRun.includes(submission: :track).find_in_batches do |batch|
        batch.each do |test_run|
          test_run.update(track_id: test_run.submission.track.id)
        end
      end
    end
  end
end
