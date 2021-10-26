FactoryBot.define do
  factory :user_mailshot, class: 'User::Mailshot' do
    user { create :user }
    mailshot_id { :test_id }
  end
end
