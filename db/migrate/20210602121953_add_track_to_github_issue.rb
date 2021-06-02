class AddTrackToGithubIssue < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :github_issues, :track, foreign_key: { to_table: :tracks }, optional: true
  end
end
