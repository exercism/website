class CreateGithubTeamMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :github_team_members do |t|
      t.string :username, null: false
      t.string :team, null: false      

      t.timestamps

      t.index %i[username team], unique: true
    end
  end
end
