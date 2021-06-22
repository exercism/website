FactoryBot.define do
  factory :contributor_team_membership, class: 'ContributorTeam::Membership' do
    team { create :contributor_team }
    user { create :user }
    status { :active }
    seniority { :medior }
    visible { true }
  end
end
