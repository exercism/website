class CreateGithubTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :github_tasks do |t|
      t.string :uuid, null: false, index: { unique: true }

      t.string :title, null: false
      t.string :repo, null: false
      t.string :issue_url, null: false, index: { unique: true }
      t.string :opened_by_username, null: true
      t.datetime :opened_at, null: false

      t.column :action, :tinyint, null: true, default: 0
      t.column :knowledge, :tinyint, null: true, default: 0
      t.column :area, :tinyint, null: true, default: 0
      t.column :size, :tinyint, null: true, default: 0
      t.column :type, :tinyint, null: true, default: 0

      t.belongs_to :track, null: true, foreign_key: true

      t.timestamps
    end
  end
end
