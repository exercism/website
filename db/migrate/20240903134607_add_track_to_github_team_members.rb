class AddTrackToGithubTeamMembers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_reference :github_team_members, :track, null: true, foreign_key: { to_table: :tracks }, if_not_exists: true
    add_index :github_team_members, %i[user_id track_id], unique: true, if_not_exists: true

    Track.find_each do |track|
      Github::TeamMember.where(team_name: track.github_team_name).update_all(track_id: track.id)
    end
  end
end
