class CreateContributorTeams < ActiveRecord::Migration[6.1]
  def change
    create_table :contributor_teams do |t|
      t.belongs_to :track, null: true, foreign_key: true
      t.string :name, null: false, index: { unique: true }
      t.string :github_name, null: false, index: { unique: true }
      t.column :type, :tinyint, null: false, default: 0      

      t.timestamps
    end
  end
end
