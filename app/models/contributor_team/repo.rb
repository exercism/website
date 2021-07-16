class ContributorTeam::Repo < ApplicationRecord
  belongs_to :team,
    class_name: "ContributorTeam",
    foreign_key: :contributor_team_id,
    inverse_of: :repos
end
