class ChangeUserIdToForeignKeyInGithubTeamMembers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    # We'll re-sync the data using Github::TeamMember::SyncMembers.()
    Github::TeamMember.delete_all

    remove_index :github_team_members, name: "index_github_team_members_on_user_id_and_team_name"
    remove_column :github_team_members, :user_id, :string

    add_reference :github_team_members, :user, null: false, foreign_key: { to_table: :users }, if_not_exists: true    
    add_index :github_team_members, %i[user_id team_name], unique: true, if_not_exists: true
  end
end
