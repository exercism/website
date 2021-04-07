class AddCurrentToMentoredTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :user_track_mentorships, :last_viewed, :boolean, default: false, null: false
  end
end
