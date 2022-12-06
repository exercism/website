class RemoveContributorTeams < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      drop_table :contributor_team_memberships
      drop_table :contributor_teams
    end
  end
end
