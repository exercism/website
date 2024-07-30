class Github::TeamMember < ApplicationRecord
  belongs_to :user,
    primary_key: :uid,
    inverse_of: :github_team_memberships,
    optional: true
end
