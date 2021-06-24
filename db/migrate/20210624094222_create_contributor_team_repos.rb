class CreateContributorTeamRepos < ActiveRecord::Migration[6.1]
  def change
    create_table :contributor_team_repos do |t|
      t.belongs_to :contributor_team, null: false, foreign_key: true
      
      t.column :github_full_name, :string, null: false

      t.index [:contributor_team_id, :github_full_name], name: "index_contributor_team_repo_on_team_id_and_github_full_name", unique: true

      t.timestamps
    end
  end
end
