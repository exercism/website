class ChangeUserIdToForeignKeyInGithubTeamMembers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    # We'll re-sync the data using Github::TeamMember::SyncMembers.()
    Github::TeamMember.delete_all

    remove_column :github_team_members, :user_id
    add_reference :github_team_members, :user_id, null: false, foreign_key: { to_table: :users }, if_not_exists: true
  end
end
