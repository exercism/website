class AddTrackReputationUserIndexToUserTracks < ActiveRecord::Migration[7.1]
  def change
    # Column order matters. reputation *second* is what lets
    # Exercise::Representation::Recache#prestigious_solution do a reverse
    # range scan with early termination (81ms on the worst representation).
    # Putting user_id second instead costs 4x (332ms).
    #
    # Already created manually on production, hence if_not_exists.
    add_index :user_tracks, %i[track_id reputation user_id],
      name: "index_user_tracks_track_reputation_user",
      if_not_exists: true
  end
end
