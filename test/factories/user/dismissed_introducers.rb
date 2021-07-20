FactoryBot.define do
  factory :user_dismissed_introducer, class: 'User::DismissedIntroducer' do
    user
    slug { "scratchpad" }

    trait :random do
      slug { SecureRandom.hex(8) }
    end
  end
end
