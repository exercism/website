class CreateUserGithubSolutionSyncers < ActiveRecord::Migration[7.0]
  def change
    create_table :user_github_solution_syncers do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.bigint :installation_id, null: false
      t.string :repo_full_name, null: false

      # Configuable options
      t.boolean :create_automatically, null: false, default: true
      t.integer :processing_method, null: false, default: 1
      t.string :main_branch_name, null: false, default: "main"

      t.string :commit_message_template, null: false
      t.string :path_template, null: false

      t.timestamps
    end
  end
end
