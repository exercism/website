class AddTrackToSubmissions < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :submissions, :track_id, :smallint, null: true
      add_index :submissions, %i[track_id], unique: false, if_not_exists: true

      Submission.includes(:exercise).find_in_batches do |batch|
        ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
          batch.each do |submission|
            submission.update(track_id: submission.exercise.track_id)
          end
        end
      end
    end
  end
end
