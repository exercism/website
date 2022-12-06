class Github::TeamMember < ApplicationRecord
  has_one :user,
    foreign_key: :uid,
    primary_key: :user_id,
    class_name: "User",
    inverse_of: :github_team_memberships,
    dependent: :destroy
end
