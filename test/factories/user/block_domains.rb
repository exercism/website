FactoryBot.define do
  factory :user_block_domain, class: 'User::BlockDomain' do
    domain { 'invalid.org' }
  end
end
