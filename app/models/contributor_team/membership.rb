class ContributorTeam::Membership < ApplicationRecord
  enum seniority: {
    junior: 0,
    medior: 1,
    senior: 2
  }

  belongs_to :team,
    class_name: "ContributorTeam",
    foreign_key: :contributor_team_id,
    inverse_of: :memberships

  belongs_to :user,
    inverse_of: :team_memberships

  def seniority = super.to_sym
end
