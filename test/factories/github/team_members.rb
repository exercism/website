FactoryBot.define do
  factory :github_team_member, class: 'Github::TeamMember' do
    user_id { SecureRandom.hex }
    team_name { SecureRandom.hex }
  end
end
