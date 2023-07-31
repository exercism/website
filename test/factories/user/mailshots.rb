FactoryBot.define do
  factory :user_mailshot, class: 'User::Mailshot' do
    user { create :user }
    mailshot { create :mailshot }
  end
end
