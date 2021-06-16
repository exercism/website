class CreateContributorTeams < ActiveRecord::Migration[6.1]
  def change
    create_table :contributor_teams do |t|
      t.belongs_to :track, null: true, foreign_key: true
      t.string :name, null: false, index: { unique: true }
      t.string :github_name, null: false, index: { unique: true }
      t.column :type, :tinyint, null: false, default: 0      

      t.timestamps
    end

    create_table :contributor_team_memberships do |t|
      t.belongs_to :contributor_team, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      
      t.column :visible, :boolean, null: false, default: true
      t.column :seniority, :tinyint, null: false, default: 0

      t.index [:contributor_team_id, :user_id], name: "index_contributor_team_memberships_on_team_id_and_user_id", unique: true

      t.timestamps
    end
  end
end
