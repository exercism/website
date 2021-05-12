class AddLastTouchedAtToUserTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :user_tracks, :last_touched_at, :datetime, null: true
    UserTrack.update_all("last_touched_at = updated_at")
    change_column_null :user_tracks, :last_touched_at, false
  end
end
