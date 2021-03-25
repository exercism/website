FactoryBot.define do
  factory :github_organization_member, class: 'Github::OrganizationMember' do
    username { SecureRandom.hex }
  end
end
