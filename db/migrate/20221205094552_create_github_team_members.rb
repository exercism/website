class CreateGithubTeamMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :github_team_members do |t|
      t.string :user_id, null: false
      t.string :team_name, null: false      

      t.timestamps

      t.index %i[user_id team_name], unique: true
    end
  end
end
