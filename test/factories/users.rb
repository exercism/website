FactoryBot.define do
  factory :user do
    email { "#{SecureRandom.hex(4)}@exercism.io" }
    name { "User" }
    password { "password" }
    handle { "handle-#{SecureRandom.hex(4)}" }
    accepted_terms_at { Date.new(2016, 12, 25) }
    accepted_privacy_policy_at { Date.new(2016, 12, 25) }
    became_mentor_at { Date.new(2016, 12, 25) }
    avatar_url { "https://avatars.githubusercontent.com/u/5624255?s=200&v=4&e_uid=xxx" }

    after(:create) do |user, _evaluator|
      # Update the avatar if we've had a placeholder in the factory
      if user.avatar_url.ends_with?("e_uid=xxx")
        user.update(
          avatar_url: "https://avatars.githubusercontent.com/u/5624255?s=200&v=4&e_uid=#{user.id}"
        )
      end
    end

    trait :not_mentor do
      became_mentor_at { nil }
    end

    trait :not_onboarded do
      accepted_terms_at { nil }
      accepted_privacy_policy_at { nil }
    end
  end
end
