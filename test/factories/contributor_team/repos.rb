FactoryBot.define do
  factory :contributor_team_repo, class: 'ContributorTeam::Repo' do
    team { create :contributor_team }
    github_full_name { "exercism/ruby" }
  end
end
