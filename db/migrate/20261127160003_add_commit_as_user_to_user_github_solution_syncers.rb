class AddCommitAsUserToUserGithubSolutionSyncers < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    add_column :user_github_solution_syncers, :commit_as_user, :boolean, default: true, null: false
  end
end
