class AddReputationToUserTrack < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_tracks, :reputation, :integer, null: false, default: 0

    UserTrack.find_each do |user_track|
      UserTrack::UpdateReputation.(user_track)
    end
  end
end
