class AddNumFinishedDiscussionsToUserTrackMentorships < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :user_track_mentorships, :num_finished_discussions, :integer, null: false, default: 0
    end
  end
end
