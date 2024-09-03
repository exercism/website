class AddTrackToGithubTeamMembers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_reference :github_team_members, :track, null: true, foreign_key: { to_table: :tracks }, if_not_exists: true
    add_index :github_team_members, %i[user_id track_id], unique: true, if_not_exists: true
  end
end
