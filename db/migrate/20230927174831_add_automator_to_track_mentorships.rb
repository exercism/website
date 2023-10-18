class AddAutomatorToTrackMentorships < ActiveRecord::Migration[7.0]
  def change
    add_column :user_track_mentorships, :automator, :boolean, null: false, default: false
  end
end
