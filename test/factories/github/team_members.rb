FactoryBot.define do
  factory :github_team_member, class: 'Github::TeamMember' do
    user { create :user }
    team_name { SecureRandom.hex }
  end
end
