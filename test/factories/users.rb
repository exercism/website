FactoryBot.define do
  factory :user do
    email { "#{SecureRandom.hex(4)}@exercism.io" }
    name { "User" }
    password { "password" }
    handle { "handle-#{SecureRandom.hex(4)}" }
    accepted_terms_at { Date.new(2016, 12, 25) }
    accepted_privacy_policy_at { Date.new(2016, 12, 25) }

    trait :not_onboarded do
      accepted_terms_at { nil }
      accepted_privacy_policy_at { nil }
    end
  end
end
