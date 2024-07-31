FactoryBot.define do
  factory :github_team_member, class: 'Github::TeamMember' do
    user { create(:user, uid: SecureRandom.hex) }
    team_name { SecureRandom.hex }
  end
end
