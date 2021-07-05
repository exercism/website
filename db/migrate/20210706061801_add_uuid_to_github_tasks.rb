class AddUuidToGithubTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :github_tasks, :uuid, :string, null: false

    add_index :github_tasks, :uuid, unique: true
  end
end
