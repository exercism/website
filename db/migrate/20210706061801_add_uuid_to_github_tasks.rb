class AddUuidToGithubTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :github_tasks, :uuid, :string, null: true
    Github::Task.update_all("`uuid` = UUID()")
    change_column_null :github_tasks, :uuid, false
    add_index :github_tasks, :uuid, unique: true
  end
end
