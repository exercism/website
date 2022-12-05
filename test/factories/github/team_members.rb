FactoryBot.define do
  factory :github_team_member, class: 'Github::TeamMember' do
    username { SecureRandom.hex }
    team { SecureRandom.hex }
  end
end
